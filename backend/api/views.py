from rest_framework import viewsets, status, filters, serializers
from rest_framework.decorators import action
from rest_framework.response import Response
from rest_framework.permissions import IsAuthenticated, AllowAny
from rest_framework.exceptions import PermissionDenied
from django_filters.rest_framework import DjangoFilterBackend
from django.utils import timezone
from django.db.models import Q

from clubs.models import Club
from events.models import Event
from registrations.models import Registration
from accounts.models import Notification, User
from accounts.permissions import IsAdminUser, IsClubAdmin

# Serializers
from .serializers import (
    EventSerializer, EventDetailSerializer, RegistrationSerializer
)
from clubs.serializers import (
    ClubSerializer,
    ClubDetailSerializer,
    ClubCreateSerializer,
)
from accounts.serializers import NotificationSerializer


# ═══════════════════════════════════════════════════════════
# CLUB VIEWSET
# ═══════════════════════════════════════════════════════════
class ClubViewSet(viewsets.ModelViewSet):
    queryset = Club.objects.filter(status='approved', is_active=True)
    serializer_class = ClubSerializer
    permission_classes = [IsAuthenticated]
    filter_backends = [DjangoFilterBackend, filters.SearchFilter, filters.OrderingFilter]
    filterset_fields = ['category']
    search_fields = ['name', 'description']
    ordering_fields = ['name', 'created_at']
    
    def get_serializer_class(self):
        if self.action == 'retrieve':
            return ClubDetailSerializer
        if self.action == 'create':
            return ClubCreateSerializer
        return ClubSerializer
    
    def get_queryset(self):
        return Club.objects.filter(status='approved', is_active=True)
    
    # ═══════════════════════════════════════════════════════
    # CREATE CLUB (Request)
    # ═══════════════════════════════════════════════════════
    def create(self, request, *args, **kwargs):
        # Check: User should not already own a club
        existing_club = Club.objects.filter(
            Q(created_by=request.user) | Q(coordinator=request.user),
            status__in=['pending', 'approved']
        ).first()
        
        if existing_club:
            return Response(
                {
                    'detail': 'You already manage a club. You cannot create more than one club.',
                    'existing_club': existing_club.name,
                },
                status=status.HTTP_400_BAD_REQUEST
            )
        
        serializer = ClubCreateSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        
        club = serializer.save(
            created_by=request.user,
            coordinator=request.user,
            status='pending',
        )
        
        # Notify superusers
        superusers = User.objects.filter(is_superuser=True)
        for su in superusers:
            Notification.objects.create(
                user=su,
                title='New Club Approval Request',
                message=f'{request.user.full_name} has requested to create a club: "{club.name}"',
                type='club_join_request',
                related_club=club,
            )
        
        return Response(
            {
                'detail': 'Club creation request submitted. Waiting for admin approval.',
                'club': ClubSerializer(club).data,
            },
            status=status.HTTP_201_CREATED
        )
    
    # ═══════════════════════════════════════════════════════
    # JOIN CLUB
    # ═══════════════════════════════════════════════════════
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
    
    # ═══════════════════════════════════════════════════════
    # LEAVE CLUB
    # ═══════════════════════════════════════════════════════
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
    
    # ═══════════════════════════════════════════════════════
    # MY CLUBS
    # ═══════════════════════════════════════════════════════
    @action(detail=False, methods=['get'])
    def my_clubs(self, request):
        clubs = request.user.joined_clubs.filter(status='approved', is_active=True)
        serializer = ClubSerializer(clubs, many=True, context={'request': request})
        return Response(serializer.data)
    
    # ═══════════════════════════════════════════════════════
    # MY MANAGED CLUB
    # ═══════════════════════════════════════════════════════
    @action(detail=False, methods=['get'])
    def my_managed_club(self, request):
        club = Club.objects.filter(
            Q(created_by=request.user) | Q(coordinator=request.user)
        ).first()
        
        if not club:
            return Response(
                {'detail': 'You do not manage any club', 'club': None},
                status=status.HTTP_200_OK
            )
        
        serializer = ClubDetailSerializer(club, context={'request': request})
        return Response({
            'club': serializer.data,
        })
    
    # ═══════════════════════════════════════════════════════
    # PENDING CLUBS (Superuser only)
    # ═══════════════════════════════════════════════════════
    @action(detail=False, methods=['get'])
    def pending(self, request):
        if not request.user.is_superuser:
            return Response(
                {'detail': 'Only superuser can view pending clubs'},
                status=status.HTTP_403_FORBIDDEN
            )
        
        clubs = Club.objects.filter(status='pending').order_by('-created_at')
        serializer = ClubSerializer(clubs, many=True, context={'request': request})
        return Response({
            'count': clubs.count(),
            'clubs': serializer.data,
        })
    
    # ═══════════════════════════════════════════════════════
    # APPROVE CLUB (Superuser only)
    # ═══════════════════════════════════════════════════════
    @action(detail=True, methods=['post'])
    def approve(self, request, pk=None):
        if not request.user.is_superuser:
            return Response(
                {'detail': 'Only superuser can approve clubs'},
                status=status.HTTP_403_FORBIDDEN
            )
        
        club = Club.objects.get(pk=pk)
        club.status = 'approved'
        club.approved_by = request.user
        club.approved_at = timezone.now()
        club.save()
        
        # Notify the creator
        Notification.objects.create(
            user=club.created_by,
            title='Club Approved! 🎉',
            message=f'Your club "{club.name}" has been approved. You are now the coordinator.',
            type='club_approved',
            related_club=club,
        )
        
        return Response({
            'detail': f'Club "{club.name}" approved successfully',
            'club': ClubSerializer(club).data,
        })
    
    # ═══════════════════════════════════════════════════════
    # REJECT CLUB (Superuser only)
    # ═══════════════════════════════════════════════════════
    @action(detail=True, methods=['post'])
    def reject(self, request, pk=None):
        if not request.user.is_superuser:
            return Response(
                {'detail': 'Only superuser can reject clubs'},
                status=status.HTTP_403_FORBIDDEN
            )
        
        club = Club.objects.get(pk=pk)
        reason = request.data.get('reason', 'No reason provided')
        
        club.status = 'rejected'
        club.rejection_reason = reason
        club.approved_by = request.user
        club.approved_at = timezone.now()
        club.save()
        
        # Notify the creator
        Notification.objects.create(
            user=club.created_by,
            title='Club Request Rejected',
            message=f'Your request to create "{club.name}" was rejected. Reason: {reason}',
            type='club_rejected',
            related_club=club,
        )
        
        return Response({
            'detail': f'Club "{club.name}" rejected',
            'club': ClubSerializer(club).data,
        })
    
    # ═══════════════════════════════════════════════════════
    # KICK MEMBER (Club Coordinator only)
    # ═══════════════════════════════════════════════════════
    @action(detail=True, methods=['post'])
    def kick_member(self, request, pk=None):
        club = self.get_object()
        
        # Only coordinator can kick
        if club.coordinator != request.user:
            return Response(
                {'detail': 'Only club coordinator can kick members'},
                status=status.HTTP_403_FORBIDDEN
            )
        
        user_id = request.data.get('user_id')
        if not user_id:
            return Response(
                {'detail': 'user_id is required'},
                status=status.HTTP_400_BAD_REQUEST
            )
        
        # Cannot kick self
        if str(user_id) == str(request.user.id):
            return Response(
                {'detail': 'You cannot kick yourself'},
                status=status.HTTP_400_BAD_REQUEST
            )
        
        try:
            member = User.objects.get(id=user_id)
        except User.DoesNotExist:
            return Response(
                {'detail': 'User not found'},
                status=status.HTTP_404_NOT_FOUND
            )
        
        if not club.members.filter(id=member.id).exists():
            return Response(
                {'detail': 'User is not a member of this club'},
                status=status.HTTP_400_BAD_REQUEST
            )
        
        # Kick the member
        club.members.remove(member)
        
        # Send notification
        Notification.objects.create(
            user=member,
            title='Removed from Club',
            message=f'You have been removed from "{club.name}" by the club admin.',
            type='kicked_from_club',
            related_club=club,
        )
        
        return Response({
            'detail': f'{member.full_name} has been removed from {club.name}',
        })


# ═══════════════════════════════════════════════════════════
# EVENT VIEWSET
# ═══════════════════════════════════════════════════════════
class EventViewSet(viewsets.ModelViewSet):
    queryset = Event.objects.all()
    serializer_class = EventSerializer
    permission_classes = [IsAuthenticated]
    filter_backends = [DjangoFilterBackend, filters.SearchFilter, filters.OrderingFilter]
    filterset_fields = ['category', 'is_past', 'club']
    search_fields = ['title', 'description', 'venue']
    ordering_fields = ['date', 'created_at']
    
    def get_serializer_class(self):
        if self.action == 'retrieve':
            return EventDetailSerializer
        return EventSerializer
    
    # ═══════════════════════════════════════════════════════
    # CREATE EVENT (Coordinator only)
    # ═══════════════════════════════════════════════════════
    def create(self, request, *args, **kwargs):
        club_id = request.data.get('club')
        
        if not club_id:
            return Response(
                {'detail': 'Club is required'},
                status=status.HTTP_400_BAD_REQUEST
            )
        
        try:
            club = Club.objects.get(id=club_id)
        except Club.DoesNotExist:
            return Response(
                {'detail': 'Club not found'},
                status=status.HTTP_404_NOT_FOUND
            )
        
        # Only coordinator can create events
        if club.coordinator != request.user:
            return Response(
                {'detail': 'Only the club coordinator can create events for this club.'},
                status=status.HTTP_403_FORBIDDEN
            )
        
        serializer = self.get_serializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        serializer.save(organizer_name=club.name)
        
        headers = self.get_success_headers(serializer.data)
        return Response(
            serializer.data,
            status=status.HTTP_201_CREATED,
            headers=headers
        )
    
    # ═══════════════════════════════════════════════════════
    # REGISTER FOR EVENT
    # ═══════════════════════════════════════════════════════
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
                {'detail': 'No spots available'},
                status=status.HTTP_400_BAD_REQUEST
            )
        
        event.registered_users.add(user)
        Registration.objects.create(user=user, event=event, status='Confirmed')
        
        return Response(
            {'detail': f'Successfully registered for {event.title}'},
            status=status.HTTP_200_OK
        )
    
    # ═══════════════════════════════════════════════════════
    # CANCEL REGISTRATION
    # ═══════════════════════════════════════════════════════
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
        
        return Response({'detail': 'Registration cancelled'})
    
    # ═══════════════════════════════════════════════════════
    # MY EVENTS
    # ═══════════════════════════════════════════════════════
    @action(detail=False, methods=['get'])
    def my_events(self, request):
        events = request.user.registered_events.all()
        serializer = self.get_serializer(events, many=True)
        return Response(serializer.data)


# ═══════════════════════════════════════════════════════════
# REGISTRATION VIEWSET
# ═══════════════════════════════════════════════════════════
class RegistrationViewSet(viewsets.ModelViewSet):
    queryset = Registration.objects.all()
    serializer_class = RegistrationSerializer
    permission_classes = [IsAuthenticated]
    
    def get_queryset(self):
        return Registration.objects.filter(user=self.request.user)
    
    @action(detail=True, methods=['post'])
    def check_in(self, request, pk=None):
        reg = self.get_object()
        reg.is_checked_in = True
        reg.checked_in_at = timezone.now()
        reg.save()
        return Response({'detail': 'Checked in successfully'})


# ═══════════════════════════════════════════════════════════
# NOTIFICATION VIEWSET
# ═══════════════════════════════════════════════════════════
class NotificationViewSet(viewsets.ModelViewSet):
    serializer_class = NotificationSerializer
    permission_classes = [IsAuthenticated]
    filter_backends = [DjangoFilterBackend, filters.OrderingFilter]
    filterset_fields = ['is_read', 'type']
    ordering_fields = ['created_at']
    
    def get_queryset(self):
        return Notification.objects.filter(user=self.request.user)
    
    @action(detail=False, methods=['get'])
    def unread_count(self, request):
        count = Notification.objects.filter(user=request.user, is_read=False).count()
        return Response({'count': count})
    
    @action(detail=False, methods=['post'])
    def mark_all_read(self, request):
        Notification.objects.filter(user=request.user, is_read=False).update(is_read=True)
        return Response({'detail': 'All notifications marked as read'})
    
    @action(detail=True, methods=['post'])
    def mark_read(self, request, pk=None):
        notif = self.get_object()
        notif.is_read = True
        notif.save()
        return Response({'detail': 'Marked as read'})