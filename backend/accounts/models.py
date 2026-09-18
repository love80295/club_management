from django.db import models
from django.contrib.auth.models import AbstractUser

class User(AbstractUser):
    USER_ROLES = (
        ('student', 'Student'),
        ('club_admin', 'Club Admin'),
        ('admin', 'Admin'),
    )
    
    profile_pic = models.ImageField(upload_to='profiles/', null=True, blank=True)
    department = models.CharField(max_length=100, blank=True, default='')
    year = models.CharField(max_length=20, blank=True, default='')
    skills = models.TextField(blank=True, default='')
    interests = models.TextField(blank=True, default='')
    role = models.CharField(max_length=20, choices=USER_ROLES, default='student')
    achievements = models.TextField(blank=True, default='')
    phone_number = models.CharField(max_length=15, blank=True, default='')
    
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)
    
    class Meta:
        db_table = 'users'
        ordering = ['-date_joined']
    
    def __str__(self):
        return self.username
    
    @property
    def full_name(self):
        return f"{self.first_name} {self.last_name}".strip() or self.username
    
    @property
    def is_admin_user(self):
        """Check if user is an admin (superuser or role='admin')"""
        return self.is_superuser or self.role == 'admin'
    
    @property
    def is_club_admin(self):
        """Check if user can manage clubs"""
        return self.is_superuser or self.role in ['admin', 'club_admin']
    
    @property
    def is_student(self):
        """Check if user is a student"""
        return self.role == 'student'
# notification class added
class Notification(models.Model):
    TYPE_CHOICES = (
        ('club_approved', 'Club Approved'),
        ('club_rejected', 'Club Rejected'),
        ('kicked_from_club', 'Kicked from Club'),
        ('club_join_request', 'Club Join Request'),
        ('event_registered', 'Event Registered'),
        ('general', 'General'),
    )
    
    user = models.ForeignKey(
        User,
        on_delete=models.CASCADE,
        related_name='notifications'
    )
    title = models.CharField(max_length=200)
    message = models.TextField()
    type = models.CharField(max_length=50, choices=TYPE_CHOICES, default='general')
    is_read = models.BooleanField(default=False)
    
    # Optional relations
    related_club = models.ForeignKey(
        'clubs.Club',
        on_delete=models.SET_NULL,
        null=True,
        blank=True,
        related_name='notifications'
    )
    related_event = models.ForeignKey(
        'events.Event',
        on_delete=models.SET_NULL,
        null=True,
        blank=True,
        related_name='notifications'
    )
    
    created_at = models.DateTimeField(auto_now_add=True)
    
    class Meta:
        db_table = 'notifications'
        ordering = ['-created_at']
    
    def __str__(self):
        return f"{self.user.username} - {self.title}"    