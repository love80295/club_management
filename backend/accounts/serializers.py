from rest_framework import serializers
from django.contrib.auth.password_validation import validate_password
from django.contrib.auth import get_user_model, authenticate
from rest_framework_simplejwt.tokens import RefreshToken
from .models import Notification
User = get_user_model()

class UserSerializer(serializers.ModelSerializer):
    full_name = serializers.SerializerMethodField()
    
    class Meta:
        model = User
        fields = [
            'id', 'username', 'email', 'first_name', 'last_name',
            'full_name', 'profile_pic', 'department', 'year',
            'skills', 'interests', 'role', 'phone_number',
            'date_joined', 'created_at'
        ]
        read_only_fields = ['id', 'username', 'date_joined', 'created_at']
    
    def get_full_name(self, obj):
        return obj.full_name

class RegisterSerializer(serializers.ModelSerializer):
    password = serializers.CharField(
        write_only=True,
        required=True,
        validators=[validate_password]
    )
    confirm_password = serializers.CharField(write_only=True, required=True)
    
    class Meta:
        model = User
        fields = [
            'username', 'email', 'password', 'confirm_password',
            'first_name', 'last_name', 'department', 'year',
            'phone_number', 'role'
        ]
    
    def validate(self, attrs):
        if attrs['password'] != attrs['confirm_password']:
            raise serializers.ValidationError(
                {"confirm_password": "Password fields didn't match."}
            )
        return attrs
    
    def create(self, validated_data):
        validated_data.pop('confirm_password')
        user = User.objects.create_user(**validated_data)
        return user

class LoginSerializer(serializers.Serializer):
    username = serializers.CharField(required=True)
    password = serializers.CharField(required=True, write_only=True)
    
    def validate(self, attrs):
        username = attrs.get('username')
        password = attrs.get('password')
        
        if username and password:
            user = authenticate(username=username, password=password)
            if not user:
                raise serializers.ValidationError(
                    'Invalid username or password.'
                )
        else:
            raise serializers.ValidationError(
                'Must include "username" and "password".'
            )
        
        attrs['user'] = user
        return attrs

class TokenSerializer(serializers.Serializer):
    refresh = serializers.CharField()
    access = serializers.CharField()
    
    class Meta:
        fields = ['refresh', 'access']
class NotificationSerializer(serializers.ModelSerializer):
    related_club_name = serializers.SerializerMethodField()
    related_event_title = serializers.SerializerMethodField()
    
    class Meta:
        model = Notification
        fields = [
            'id', 'title', 'message', 'type',
            'is_read',
            'related_club', 'related_club_name',
            'related_event', 'related_event_title',
            'created_at'
        ]
        read_only_fields = ['id', 'created_at']
    
    def get_related_club_name(self, obj):
        if obj.related_club:
            return obj.related_club.name
        return None
    
    def get_related_event_title(self, obj):
        if obj.related_event:
            return obj.related_event.title
        return None        