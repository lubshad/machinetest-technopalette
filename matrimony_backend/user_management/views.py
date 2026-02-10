from rest_framework import viewsets, permissions, status
from rest_framework.decorators import action
from rest_framework.response import Response
from django.contrib.auth import get_user_model
from django.contrib.auth.models import Group, Permission
from .serializers import (
    UserSerializer, GroupSerializer, PermissionSerializer,
    AddGroupsSerializer, RemoveGroupsSerializer
)
from alanasi.pagination import CustomPagination

User = get_user_model()

class UserViewSet(viewsets.ModelViewSet):
    """
    API endpoint that allows users to be viewed or edited.
    """
    queryset = User.objects.filter(rider_profile__isnull=True, driver_profile__isnull=True).prefetch_related('groups', 'user_permissions', 'groups__permissions').order_by('-date_joined')
    serializer_class = UserSerializer
    pagination_class = CustomPagination
    permission_classes = [permissions.IsAdminUser]

    @action(detail=True, methods=['post'], url_path='add-groups')
    def add_groups(self, request, pk=None):
        """
        Add groups to a user.
        POST /api/users/users/{id}/add-groups/
        Body: {"group_ids": [1, 2, 3]}
        """
        user = self.get_object()
        serializer = AddGroupsSerializer(data=request.data)
        
        if serializer.is_valid():
            group_ids = serializer.validated_data['group_ids']
            groups = Group.objects.filter(id__in=group_ids)
            
            # Check if all groups exist
            found_ids = set(groups.values_list('id', flat=True))
            requested_ids = set(group_ids)
            missing_ids = requested_ids - found_ids
            
            if missing_ids:
                return Response(
                    {'error': f'Groups with IDs {list(missing_ids)} do not exist.'},
                    status=status.HTTP_400_BAD_REQUEST
                )
            
            # Add groups (using add() to avoid removing existing groups)
            user.groups.add(*groups)
            
            # Return updated user
            user_serializer = UserSerializer(user)
            return Response({
                'message': f'Successfully added {len(groups)} group(s) to user.',
                'user': user_serializer.data
            }, status=status.HTTP_200_OK)
        
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)

    @action(detail=True, methods=['post'], url_path='remove-groups')
    def remove_groups(self, request, pk=None):
        """
        Remove groups from a user.
        POST /api/users/users/{id}/remove-groups/
        Body: {"group_ids": [1, 2, 3]}
        """
        user = self.get_object()
        serializer = RemoveGroupsSerializer(data=request.data)
        
        if serializer.is_valid():
            group_ids = serializer.validated_data['group_ids']
            groups = Group.objects.filter(id__in=group_ids)
            
            # Remove groups
            removed_count = user.groups.filter(id__in=group_ids).count()
            user.groups.remove(*groups)
            
            # Return updated user
            user_serializer = UserSerializer(user)
            return Response({
                'message': f'Successfully removed {removed_count} group(s) from user.',
                'user': user_serializer.data
            }, status=status.HTTP_200_OK)
        
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)

    def perform_destroy(self, instance):
        """
        Delete all auth tokens for the user before deleting the user.
        """
        from rest_framework.authtoken.models import Token
        Token.objects.filter(user=instance).delete()
        instance.delete()

    def perform_update(self, serializer):
        """
        If password is being updated, delete all auth tokens for the user.
        """
        # Check if password is in validated_data explicitly before save(), 
        # as the serializer's update() method pops it.
        password_updated = 'password' in serializer.validated_data
        
        user = serializer.save()
        
        if password_updated:
            from rest_framework.authtoken.models import Token
            Token.objects.filter(user=user).delete()

class GroupViewSet(viewsets.ModelViewSet):
    """
    API endpoint that allows groups to be viewed or edited.
    """
    queryset = Group.objects.all().order_by('name')
    serializer_class = GroupSerializer
    pagination_class = CustomPagination
    permission_classes = [permissions.IsAdminUser]

class PermissionViewSet(viewsets.ModelViewSet):
    """
    API endpoint that allows permissions to be viewed or edited.
    Filter permissions to show only relevant models.
    """
    serializer_class = PermissionSerializer
    pagination_class = CustomPagination
    permission_classes = [permissions.IsAdminUser]
    queryset = Permission.objects.all()

    def get_queryset(self):
        from django.db.models import Q
        return Permission.objects.filter(
            Q(content_type__app_label='vehicles', content_type__model='vehicle') |
            Q(content_type__app_label='riders', content_type__model='rider') |
            Q(content_type__app_label='drivers', content_type__model='driver') |
            Q(content_type__app_label='rides', content_type__model='ride') |
            Q(content_type__app_label='service_areas', content_type__model='servicearea') |
            Q(content_type__app_label='settings', content_type__model='faresettings') |
            Q(content_type__app_label='auth', content_type__model='user') |
            Q(content_type__app_label='auth', content_type__model='group')
        ).order_by('id')
