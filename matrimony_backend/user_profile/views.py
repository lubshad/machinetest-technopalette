from rest_framework import viewsets, status
from rest_framework.decorators import action
from rest_framework.response import Response
from rest_framework.permissions import IsAuthenticated, AllowAny
from rest_framework.authtoken.models import Token
from django.contrib.auth import get_user_model
from django.db import transaction
from .models import UserProfile
from .serializers import UserProfileSerializer, UserProfileCreateUpdateSerializer

User = get_user_model()


from matrimony.pagination import CustomPagination

class UserProfileViewSet(viewsets.ModelViewSet):
    """
    ViewSet for UserProfile operations.
    Provides CRUD operations for user profiles.
    """
    permission_classes = [IsAuthenticated]
    serializer_class = UserProfileSerializer
    pagination_class = CustomPagination

    # Filter and Search
    filterset_fields = {
        'gender': ['exact'],
        'city': ['icontains', 'exact'],
        'state': ['icontains', 'exact'],
        'country': ['icontains', 'exact'],
        'family_type': ['exact'],
        'family_status': ['exact'],
        'height': ['gte', 'lte'],
        'weight': ['gte', 'lte'],
        'siblings': ['exact', 'gte', 'lte'],
    }
    search_fields = ['user__first_name', 'user__last_name', 'user__email', 'city', 'state', 'bio']
    ordering_fields = ['created_at', 'height', 'weight']
    
    def get_queryset(self):
        """Return profiles - admins see all, users see others (excluding self and same gender)"""
        if self.request.user.is_staff:
            return UserProfile.objects.all()
        
        # Initial queryset excluding self
        queryset = UserProfile.objects.exclude(user=self.request.user)
        
        # If user has a profile, exclude same gender
        if hasattr(self.request.user, 'profile'):
            user_gender = self.request.user.profile.gender
            if user_gender:
                queryset = queryset.exclude(gender=user_gender)
        
        return queryset.order_by('-created_at')
    
    def get_serializer_class(self):
        """Use different serializers for read and write operations"""
        if self.action in ['create', 'update', 'partial_update']:
            return UserProfileCreateUpdateSerializer
        return UserProfileSerializer
    
    def perform_create(self, serializer):
        """Create profile for the current user"""
        serializer.save(user=self.request.user)
    
    @action(detail=False, methods=['post'], permission_classes=[AllowAny])
    def register(self, request):
        """
        Register a new user with profile information.
        Accepts: email, password, first_name, last_name, phone_number, gender
        Returns: token and user profile data
        """
        # Validate required fields
        required_fields = ['email', 'password', 'first_name', 'last_name', 'phone_number', 'gender']
        missing_fields = [field for field in required_fields if field not in request.data]
        if missing_fields:
            return Response(
                {'detail': f'Missing required fields: {", ".join(missing_fields)}'},
                status=status.HTTP_400_BAD_REQUEST
            )
        
        email = request.data.get('email')
        password = request.data.get('password')
        first_name = request.data.get('first_name')
        last_name = request.data.get('last_name')
        phone_number = request.data.get('phone_number')
        gender = request.data.get('gender')
        
        # Validate gender value
        if gender not in ['Male', 'Female']:
            return Response(
                {'detail': 'Gender must be either "Male" or "Female"'},
                status=status.HTTP_400_BAD_REQUEST
            )
        
        # Check if email already exists
        if User.objects.filter(email=email).exists():
            return Response(
                {'detail': 'Email already exists'},
                status=status.HTTP_400_BAD_REQUEST
            )
        
        # Use email as username
        username = email
        
        # Check if username already exists (shouldn't happen if email is unique, but just in case)
        if User.objects.filter(username=username).exists():
            # If email as username exists, try using email prefix + random suffix
            import uuid
            username = f"{email.split('@')[0]}_{uuid.uuid4().hex[:6]}"
        print("ik")
        try:
            with transaction.atomic():
                # Create user with email as username
                user = User.objects.create_user(
                    username=username,
                    email=email,
                    password=password,
                    first_name=first_name,
                    last_name=last_name
                )
                
                # Create profile with gender and phone_number
                profile = UserProfile.objects.create(
                    user=user,
                    gender=gender,
                    phone_number=phone_number
                )
                
                # Generate auth token
                token, _ = Token.objects.get_or_create(user=user)
                
                # Return token and profile data
                return Response(
                    {
                        'token': token.key,
                        'user': UserProfileSerializer(profile).data
                    },
                    status=status.HTTP_201_CREATED
                )
        except Exception as e:
            return Response(
                {'detail': str(e)},
                status=status.HTTP_400_BAD_REQUEST
            )
    
    @action(detail=False, methods=['get'])
    def me(self, request):
        """Get the current user's profile"""
        try:
            profile = UserProfile.objects.get(user=request.user)
            serializer = self.get_serializer(profile)
            return Response(serializer.data)
        except UserProfile.DoesNotExist:
            return Response(
                {'detail': 'Profile not found'},
                status=status.HTTP_404_NOT_FOUND
            )
    
    @action(detail=False, methods=['post'])
    def toggle_interest(self, request):
        """Toggle interest in another profile"""
        profile_id = request.data.get('profile_id')
        if not profile_id:
            return Response(
                {'detail': 'profile_id is required'},
                status=status.HTTP_400_BAD_REQUEST
            )
        
        try:
            target_profile = UserProfile.objects.get(pk=profile_id)
            user_profile = UserProfile.objects.get(user=request.user)
            
            if target_profile == user_profile:
                return Response(
                    {'detail': 'You cannot express interest in your own profile'},
                    status=status.HTTP_400_BAD_REQUEST
                )
            
            if user_profile.interests.filter(pk=profile_id).exists():
                user_profile.interests.remove(target_profile)
                is_interested = False
                message = "Interest removed"
            else:
                user_profile.interests.add(target_profile)
                is_interested = True
                message = "Interest expressed"
            
            return Response({
                'is_interested': is_interested,
                'message': message
            }, status=status.HTTP_200_OK)
            
        except UserProfile.DoesNotExist:
            return Response(
                {'detail': 'Target profile not found'},
                status=status.HTTP_404_NOT_FOUND
            )

    @action(detail=False, methods=['get'])
    def my_interests(self, request):
        """List profiles the current user is interested in"""
        try:
            user_profile = UserProfile.objects.get(user=request.user)
            interests = user_profile.interests.all().order_by('-created_at')
            
            page = self.paginate_queryset(interests)
            if page is not None:
                serializer = self.get_serializer(page, many=True)
                return self.get_paginated_response(serializer.data)
            
            serializer = self.get_serializer(interests, many=True)
            return Response(serializer.data)
        except UserProfile.DoesNotExist:
            return Response([], status=status.HTTP_200_OK)

    @action(detail=False, methods=['post', 'put', 'patch'])
    def update_me(self, request):
        """Update the current user's profile"""
        profile, created = UserProfile.objects.get_or_create(user=request.user)
        
        # Update User model fields if provided
        user = request.user
        user_updated = False
        
        if 'first_name' in request.data:
            user.first_name = request.data['first_name']
            user_updated = True
        
        if 'last_name' in request.data:
            user.last_name = request.data['last_name']
            user_updated = True
        
        if 'email' in request.data:
            new_email = request.data['email']
            # Check if email is already taken by another user
            if User.objects.filter(email=new_email).exclude(id=user.id).exists():
                return Response(
                    {'detail': 'Email already exists'},
                    status=status.HTTP_400_BAD_REQUEST
                )
            user.email = new_email
            user_updated = True
        
        if user_updated:
            user.save()
        
        # Update UserProfile fields
        serializer = UserProfileCreateUpdateSerializer(
            profile,
            data=request.data,
            partial=request.method == 'PATCH'
        )
        serializer.is_valid(raise_exception=True)
        serializer.save()
        
        # Return full profile data
        return Response(
            UserProfileSerializer(profile).data,
            status=status.HTTP_200_OK
        )
