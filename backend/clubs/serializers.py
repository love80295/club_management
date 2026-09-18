from rest_framework import serializers
from .models import Club
from accounts.models import User


class ClubSerializer(serializers.ModelSerializer):
    member_count = serializers.IntegerField(source='members.count', read_only=True)
    is_joined = serializers.SerializerMethodField()
    coordinator_name = serializers.SerializerMethodField()
    created_by_name = serializers.SerializerMethodField()
    
    class Meta:
        model = Club
        fields = [
            'id', 'name', 'description', 'category', 'logo',
            'instagram_handle', 'club_email',  # ← NEW
            'coordinator', 'coordinator_name',
            'created_by', 'created_by_name',
            'member_count', 'is_joined',
            'status', 'rejection_reason',
            'is_active',
            'created_at', 'updated_at'
        ]
        read_only_fields = [
            'id', 'coordinator', 'created_by',
            'status', 'rejection_reason',
            'created_at', 'updated_at'
        ]
    
    def get_is_joined(self, obj):
        request = self.context.get('request')
        if request and request.user.is_authenticated:
            return obj.members.filter(id=request.user.id).exists()
        return False
    
    def get_coordinator_name(self, obj):
        if obj.coordinator:
            return obj.coordinator.full_name
        return ''
    
    def get_created_by_name(self, obj):
        if obj.created_by:
            return obj.created_by.full_name
        return ''


class ClubCreateSerializer(serializers.ModelSerializer):
    """Serializer for creating a club request"""
    
    class Meta:
        model = Club
        fields = [
            'name', 'description', 'category', 'logo',
            'instagram_handle', 'club_email',  # ← NEW
        ]
    
    def validate_instagram_handle(self, value):
        """Auto-add @ if not present"""
        if value and not value.startswith('@'):
            value = '@' + value
        return value
    
    def validate_club_email(self, value):
        """Validate email format if provided"""
        if value:
            from django.core.validators import validate_email
            from django.core.exceptions import ValidationError
            try:
                validate_email(value)
            except ValidationError:
                raise serializers.ValidationError('Enter a valid email address.')
        return value
    
    def validate_name(self, value):
        """Check for duplicate club name"""
        if Club.objects.filter(name__iexact=value).exists():
            raise serializers.ValidationError(
                'A club with this name already exists.'
            )
        return value


class ClubApprovalSerializer(serializers.Serializer):
    """Serializer for approve/reject actions"""
    action = serializers.ChoiceField(choices=['approve', 'reject'])
    reason = serializers.CharField(required=False, allow_blank=True)


class ClubDetailSerializer(serializers.ModelSerializer):
    member_count = serializers.IntegerField(source='members.count', read_only=True)
    members = serializers.SerializerMethodField()
    is_joined = serializers.SerializerMethodField()
    is_coordinator = serializers.SerializerMethodField()
    coordinator_name = serializers.SerializerMethodField()
    created_by_name = serializers.SerializerMethodField()
    
    class Meta:
        model = Club
        fields = '__all__'
    
    def get_members(self, obj):
        members = obj.members.all()[:50]  # Limit to 50
        return [
            {
                'id': m.id,
                'username': m.username,
                'name': m.full_name,
                'email': m.email,
                'department': m.department,
                'year': m.year,
                'profile_pic': m.profile_pic.url if m.profile_pic else None,
                'is_coordinator': m.id == obj.coordinator_id,
            }
            for m in members
        ]
    
    def get_is_joined(self, obj):
        request = self.context.get('request')
        if request and request.user.is_authenticated:
            return obj.members.filter(id=request.user.id).exists()
        return False
    
    def get_is_coordinator(self, obj):
        request = self.context.get('request')
        if request and request.user.is_authenticated:
            return obj.coordinator_id == request.user.id
        return False
    
    def get_coordinator_name(self, obj):
        if obj.coordinator:
            return obj.coordinator.full_name
        return ''
    
    def get_created_by_name(self, obj):
        if obj.created_by:
            return obj.created_by.full_name
        return ''