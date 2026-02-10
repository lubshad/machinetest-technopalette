from django.contrib.auth import get_user_model
from django.contrib.auth.models import Group, Permission
from rest_framework import serializers

User = get_user_model()

class PermissionSerializer(serializers.ModelSerializer):
    model_name = serializers.CharField(source='content_type.model', read_only=True)
    
    class Meta:
        model = Permission
        fields = ['id', 'name', 'content_type', 'codename', 'model_name']




class GroupSerializer(serializers.ModelSerializer):
    class Meta:
        model = Group
        fields = ['id', 'name', 'permissions']

    def to_representation(self, instance):
        response = super().to_representation(instance)
        response['permissions'] = PermissionSerializer(instance.permissions.all(), many=True).data
        return response



class UserSerializer(serializers.ModelSerializer):
    password = serializers.CharField(write_only=True, required=False)

    class Meta:
        model = User
        fields = [
            'id', 'username', 'email', 'first_name', 'last_name', 
            'is_active', 'is_staff', 'is_superuser', 
            'groups',
            'password'
        ]

    def to_representation(self, instance):
        response = super().to_representation(instance)
        response['groups'] = GroupSerializer(instance.groups.all(), many=True).data
        return response

    def create(self, validated_data):
        password = validated_data.pop('password', None)
        groups = validated_data.pop('groups', [])
        
        user = User.objects.create(**validated_data)
        
        if password:
            user.set_password(password)
            user.save()
            
        if groups:
            user.groups.set(groups)
            
        return user

    def update(self, instance, validated_data):
        password = validated_data.pop('password', None)
        groups = validated_data.pop('groups', None)
        
        for attr, value in validated_data.items():
            setattr(instance, attr, value)
            
        if password:
            instance.set_password(password)
            
        instance.save()
        
        if groups is not None:
            instance.groups.set(groups)
            
        return instance

    def get_permissions(self, obj):
        permissions = Permission.objects.filter(group__user=obj).distinct()
        return PermissionSerializer(permissions, many=True).data


class AddGroupsSerializer(serializers.Serializer):
    """Serializer for adding groups to a user."""
    group_ids = serializers.ListField(
        child=serializers.IntegerField(),
        help_text="List of group IDs to add to the user"
    )


class RemoveGroupsSerializer(serializers.Serializer):
    """Serializer for removing groups from a user."""
    group_ids = serializers.ListField(
        child=serializers.IntegerField(),
        help_text="List of group IDs to remove from the user"
    )
