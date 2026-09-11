from rest_framework import serializers
from clubs.models import Club
from events.models import Event
from registrations.models import Registration
from accounts.models import User


class ClubSerializer(serializers.ModelSerializer):
    member_count = serializers.IntegerField(source='members.count', read_only=True)
    is_joined = serializers.SerializerMethodField()
    
    class Meta:
        model = Club
        fields = [
            'id', 'name', 'description', 'category', 'logo',
            'coordinator', 'member_count', 'is_joined',
            'created_at', 'updated_at'
        ]
        read_only_fields = ['id', 'created_at', 'updated_at']
    
    def get_is_joined(self, obj):
        request = self.context.get('request')
        if request and request.user.is_authenticated:
            return obj.members.filter(id=request.user.id).exists()
        return False


class ClubDetailSerializer(serializers.ModelSerializer):
    member_count = serializers.IntegerField(source='members.count', read_only=True)
    members = serializers.SerializerMethodField()
    events = serializers.SerializerMethodField()
    is_joined = serializers.SerializerMethodField()
    
    class Meta:
        model = Club
        fields = '__all__'
    
    def get_members(self, obj):
        members = obj.members.all()[:10]  # Limit to 10
        return [
            {
                'id': member.id,
                'name': member.full_name,
                'email': member.email,
                'profile_pic': member.profile_pic.url if member.profile_pic else None,
            }
            for member in members
        ]
    
    def get_events(self, obj):
        events = obj.events.all()[:10]  # Limit to 10
        return EventSerializer(events, many=True).data
    
    def get_is_joined(self, obj):
        request = self.context.get('request')
        if request and request.user.is_authenticated:
            return obj.members.filter(id=request.user.id).exists()
        return False


class EventSerializer(serializers.ModelSerializer):
    club_name = serializers.CharField(source='club.name', read_only=True)
    registered_count = serializers.IntegerField(source='registered_users.count', read_only=True)
    available_spots = serializers.IntegerField(read_only=True)
    is_registered = serializers.SerializerMethodField()
    is_full = serializers.BooleanField(read_only=True)
    
    class Meta:
        model = Event
        fields = [
            'id', 'title', 'description', 'date', 'time', 'venue',
            'category', 'club', 'club_name', 'organizer_name',
            'max_participants', 'registered_count', 'available_spots',
            'is_full', 'is_registered', 'image', 'is_past',
            'created_at', 'updated_at'
        ]
        read_only_fields = ['id', 'created_at', 'updated_at']
    
    def get_is_registered(self, obj):
        request = self.context.get('request')
        if request and request.user.is_authenticated:
            return obj.registered_users.filter(id=request.user.id).exists()
        return False


class EventDetailSerializer(serializers.ModelSerializer):
    club = ClubSerializer(read_only=True)
    registered_count = serializers.IntegerField(source='registered_users.count', read_only=True)
    available_spots = serializers.IntegerField(read_only=True)
    is_registered = serializers.SerializerMethodField()
    participants = serializers.SerializerMethodField()
    
    class Meta:
        model = Event
        fields = '__all__'
    
    def get_is_registered(self, obj):
        request = self.context.get('request')
        if request and request.user.is_authenticated:
            return obj.registered_users.filter(id=request.user.id).exists()
        return False
    
    def get_participants(self, obj):
        users = obj.registered_users.all()[:20]  # Limit to 20
        return [
            {
                'id': user.id,
                'name': user.full_name,
                'email': user.email,
            }
            for user in users
        ]


class RegistrationSerializer(serializers.ModelSerializer):
    event_title = serializers.CharField(source='event.title', read_only=True)
    event_date = serializers.DateField(source='event.date', read_only=True)
    event_time = serializers.TimeField(source='event.time', read_only=True)
    event_venue = serializers.CharField(source='event.venue', read_only=True)
    user_name = serializers.CharField(source='user.full_name', read_only=True)
    
    class Meta:
        model = Registration
        fields = [
            'id', 'user', 'user_name', 'event', 'event_title',
            'event_date', 'event_time', 'event_venue',
            'status', 'registered_at', 'updated_at',
            'is_checked_in', 'checked_in_at', 'qr_code'
        ]
        read_only_fields = [
            'id', 'user', 'registered_at', 'updated_at',
            'qr_code', 'is_checked_in', 'checked_in_at'
        ]