from rest_framework import viewsets, status, filters
from rest_framework.decorators import action
from rest_framework.response import Response
from rest_framework.permissions import IsAuthenticated, AllowAny
from django_filters.rest_framework import DjangoFilterBackend
from django.utils import timezone

from clubs.models import Club
from events.models import Event
from registrations.models import Registration
from accounts.permissions import IsAdminUser, IsClubAdmin, IsOwnerOrAdmin

from .serializers import (
    ClubSerializer, EventSerializer, RegistrationSerializer,
    ClubDetailSerializer, EventDetailSerializer
)


class ClubViewSet(viewsets.ModelViewSet):
    """
    Club ViewSet with role-based permissions
    - GET (list/retrieve): Any authenticated user
    - POST (create): Admin/Club Admin only
    - PUT/PATCH: Admin or Club Coordinator
    - DELETE: Admin only
    """
    queryset = Club.objects.all()
    serializer_class = ClubSerializer
    filter_backends = [DjangoFilterBackend, filters.SearchFilter, filters.OrderingFilter]
    filterset_fields = ['category', 'is_active']
    search_fields = ['name', 'description']
    ordering_fields = ['name', 'created_at']
    
    def get_permissions(self):
        """
        Different permissions for different actions
        """
        if self.action in ['create']:
            permission_classes = [IsClubAdmin]
        elif self.action in ['update', 'partial_update', 'destroy']:
            permission_classes = [IsClubAdmin]
        elif self.action in ['join', 'leave', 'my_clubs']:
            permission_classes = [IsAuthenticated]
        else:
            permission_classes = [IsAuthenticated]
        return [permission() for permission in permission_classes]
    
    def get_serializer_class(self):
        if self.action == 'retrieve':
            return ClubDetailSerializer
        return ClubSerializer
    
    def perform_create(self, serializer):
        """Set the coordinator to the current user if not provided"""
        if not serializer.validated_data.get('coordinator'):
            serializer.save(coordinator=self.request.user)
        else:
            serializer.save()
    
    @action(detail=True, methods=['post'])
    def join(self, request, pk=None):
        club = self.get_object()
        user = request.user
        
        if club.members.filter(id=user.id).exists():
            return Response(
                {'detail': 'You are already a member of this club'},
                status=status.HTTP_400_BAD_REQUEST
            )
        
        club.members.add(user)
        return Response(
            {'detail': f'Successfully joined {club.name}'},
            status=status.HTTP_200_OK
        )
    
    @action(detail=True, methods=['post'])
    def leave(self, request, pk=None):
        club = self.get_object()
        user = request.user
        
        if not club.members.filter(id=user.id).exists():
            return Response(
                {'detail': 'You are not a member of this club'},
                status=status.HTTP_400_BAD_REQUEST
            )
        
        if club.coordinator == user:
            return Response(
                {'detail': 'Coordinator cannot leave the club. Transfer ownership first.'},
                status=status.HTTP_400_BAD_REQUEST
            )
        
        club.members.remove(user)
        return Response(
            {'detail': f'Successfully left {club.name}'},
            status=status.HTTP_200_OK
        )
    
    @action(detail=False, methods=['get'])
    def my_clubs(self, request):
        clubs = request.user.joined_clubs.all()
        serializer = self.get_serializer(clubs, many=True)
        return Response(serializer.data)
    
    @action(detail=False, methods=['get'])
    def managed_clubs(self, request):
        """Get clubs managed by current admin"""
        if not request.user.is_club_admin:
            return Response(
                {'detail': 'You do not have permission to view managed clubs'},
                status=status.HTTP_403_FORBIDDEN
            )
        clubs = Club.objects.filter(coordinator=request.user)
        serializer = self.get_serializer(clubs, many=True)
        return Response(serializer.data)


class EventViewSet(viewsets.ModelViewSet):
    """
    Event ViewSet with role-based permissions
    - GET: Any authenticated user
    - POST: Admin/Club Admin only
    - PUT/PATCH/DELETE: Admin or Club Coordinator
    """
    queryset = Event.objects.all()
    serializer_class = EventSerializer
    filter_backends = [DjangoFilterBackend, filters.SearchFilter, filters.OrderingFilter]
    filterset_fields = ['category', 'is_past', 'club']
    search_fields = ['title', 'description', 'venue']
    ordering_fields = ['date', 'created_at']
    
    def get_permissions(self):
        if self.action in ['create']:
            permission_classes = [IsClubAdmin]
        elif self.action in ['update', 'partial_update', 'destroy']:
            permission_classes = [IsClubAdmin]
        else:
            permission_classes = [IsAuthenticated]
        return [permission() for permission in permission_classes]
    
    def get_serializer_class(self):
        if self.action == 'retrieve':
            return EventDetailSerializer
        return EventSerializer
    
    @action(detail=True, methods=['post'])
    def register(self, request, pk=None):
        event = self.get_object()
        user = request.user
        
        if event.registered_users.filter(id=user.id).exists():
            return Response(
                {'detail': 'You are already registered for this event'},
                status=status.HTTP_400_BAD_REQUEST
            )
        
        if event.registered_users.count() >= event.max_participants:
            return Response(
                {'detail': 'No spots available for this event'},
                status=status.HTTP_400_BAD_REQUEST
            )
        
        event.registered_users.add(user)
        Registration.objects.create(
            user=user,
            event=event,
            status='Confirmed'
        )
        
        return Response(
            {'detail': f'Successfully registered for {event.title}'},
            status=status.HTTP_200_OK
        )
    
    @action(detail=True, methods=['post'])
    def cancel_registration(self, request, pk=None):
        event = self.get_object()
        user = request.user
        
        if not event.registered_users.filter(id=user.id).exists():
            return Response(
                {'detail': 'You are not registered for this event'},
                status=status.HTTP_400_BAD_REQUEST
            )
        
        event.registered_users.remove(user)
        Registration.objects.filter(user=user, event=event).delete()
        
        return Response(
            {'detail': f'Registration cancelled for {event.title}'},
            status=status.HTTP_200_OK
        )
    
    @action(detail=False, methods=['get'])
    def my_events(self, request):
        events = request.user.registered_events.all()
        serializer = self.get_serializer(events, many=True)
        return Response(serializer.data)


class RegistrationViewSet(viewsets.ModelViewSet):
    queryset = Registration.objects.all()
    serializer_class = RegistrationSerializer
    permission_classes = [IsAuthenticated]
    filter_backends = [DjangoFilterBackend, filters.OrderingFilter]
    filterset_fields = ['status', 'event']
    ordering_fields = ['registered_at']
    
    def get_queryset(self):
        return Registration.objects.filter(user=self.request.user)
    
    @action(detail=True, methods=['post'])
    def check_in(self, request, pk=None):
        registration = self.get_object()
        
        if registration.is_checked_in:
            return Response(
                {'detail': 'You are already checked in'},
                status=status.HTTP_400_BAD_REQUEST
            )
        
        registration.is_checked_in = True
        registration.checked_in_at = timezone.now()
        registration.save()
        
        return Response(
            {'detail': 'Successfully checked in'},
            status=status.HTTP_200_OK
        )