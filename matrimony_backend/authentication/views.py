from django.contrib.auth import get_user_model
from rest_framework import status
from rest_framework.permissions import AllowAny, IsAuthenticated
from rest_framework.response import Response
from rest_framework.authtoken.models import Token
from rest_framework.views import APIView
from .authentication import TokenOrBearerAuthentication

from .serializers import (
    RegisterSerializer,
    LoginSerializer,
    PasswordChangeSerializer,
)

from user_management.serializers import UserSerializer




User = get_user_model()


class RegisterView(APIView):
    permission_classes = [AllowAny]

    def post(self, request):
        serializer = RegisterSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        user = serializer.save()
        token, _ = Token.objects.get_or_create(user=user)
        return Response({'token': token.key, 'user': UserSerializer(user).data}, status=status.HTTP_201_CREATED)


class LoginView(APIView):
    permission_classes = [AllowAny]

    def post(self, request):
        serializer = LoginSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        user = serializer.validated_data['user']
        token, _ = Token.objects.get_or_create(user=user)
        return Response({'token': token.key, 'user': UserSerializer(user).data}, status=status.HTTP_200_OK)


class LogoutView(APIView):
    authentication_classes = [TokenOrBearerAuthentication]
    permission_classes = [AllowAny]
    
    def post(self, request):
        if request.user.is_authenticated:
            # Unregister all notification devices on logout
            try:
                from notification.services import FirebaseNotificationService
                firebase_service = FirebaseNotificationService()
                firebase_service.unregister_user_devices(request.user)
            except Exception:
                pass
                
            # Token.objects.filter(user=request.user).delete()
        return Response(status=status.HTTP_204_NO_CONTENT)


class ProfileView(APIView):
    authentication_classes = [TokenOrBearerAuthentication]
    permission_classes = [IsAuthenticated]
    
    def get(self, request):
        return Response(UserSerializer(request.user).data)

    def put(self, request):
        serializer = UserSerializer(request.user, data=request.data, partial=True)
        serializer.is_valid(raise_exception=True)
        serializer.save()
        return Response(serializer.data)


class PasswordChangeView(APIView):
    authentication_classes = [TokenOrBearerAuthentication]
    permission_classes = [IsAuthenticated]
    
    def put(self, request):
        serializer = PasswordChangeSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        if not request.user.check_password(serializer.validated_data['old_password']):
            return Response({'detail': 'Old password is incorrect'}, status=status.HTTP_400_BAD_REQUEST)
        request.user.set_password(serializer.validated_data['new_password'])
        request.user.save()
        Token.objects.filter(user=request.user).delete()
        new_token = Token.objects.create(user=request.user)
        return Response({'token': new_token.key})


