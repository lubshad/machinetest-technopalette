from rest_framework import serializers
from .models import UserProfile
from django.contrib.auth import get_user_model

User = get_user_model()


class UserProfileSerializer(serializers.ModelSerializer):
    """Serializer for UserProfile model"""
    
    # Read-only fields from User model
    username = serializers.CharField(source='user.username', read_only=True)
    email = serializers.EmailField(source='user.email', read_only=True)
    first_name = serializers.CharField(source='user.first_name', read_only=True)
    last_name = serializers.CharField(source='user.last_name', read_only=True)
    
    class Meta:
        model = UserProfile
        fields = [
            'user',
            'username',
            'email',
            'first_name',
            'last_name',
            'photo',
            'gender',
            'phone_number',
            'height',
            'weight',
            'address_line1',
            'address_line2',
            'city',
            'state',
            'country',
            'postal_code',
            'father_name',
            'mother_name',
            'siblings',
            'family_type',
            'family_status',
            'bio',
            'interests',
            'created_at',
            'updated_at',
        ]
        read_only_fields = ['user', 'created_at', 'updated_at']


class UserProfileCreateUpdateSerializer(serializers.ModelSerializer):
    """Serializer for creating/updating UserProfile"""
    
    class Meta:
        model = UserProfile
        fields = [
            'photo',
            'gender',
            'phone_number',
            'height',
            'weight',
            'address_line1',
            'address_line2',
            'city',
            'state',
            'country',
            'postal_code',
            'father_name',
            'mother_name',
            'siblings',
            'family_type',
            'family_status',
            'bio',
        ]
