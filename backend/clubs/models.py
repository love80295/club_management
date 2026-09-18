from django.db import models
from django.conf import settings


class Club(models.Model):
    CATEGORIES = (
        ('Technical', 'Technical'),
        ('Cultural', 'Cultural'),
        ('Sports', 'Sports'),
        ('Academic', 'Academic'),
        ('Arts', 'Arts'),
    )
    
    STATUS_CHOICES = (
        ('pending', 'Pending Approval'),
        ('approved', 'Approved'),
        ('rejected', 'Rejected'),
    )
    
    name = models.CharField(max_length=100, unique=True)
    description = models.TextField()
    instagram_handle = models.CharField(max_length=100, blank=True, default='')
    club_email = models.EmailField(blank=True, default='')
    logo = models.ImageField(upload_to='clubs/', null=True, blank=True)
    category = models.CharField(max_length=50, choices=CATEGORIES)
    
    # Coordinator (Club Admin) - the one who manages the club
    coordinator = models.ForeignKey(
        settings.AUTH_USER_MODEL,
        on_delete=models.SET_NULL,
        null=True,
        blank=True,
        related_name='coordinated_clubs'
    )
    
    # Who created the club (the applicant)
    created_by = models.ForeignKey(
        settings.AUTH_USER_MODEL,
        on_delete=models.CASCADE,
        related_name='created_clubs',
        null=True,
        blank=True,
    )
    
    # Members
    members = models.ManyToManyField(
        settings.AUTH_USER_MODEL,
        related_name='joined_clubs',
        blank=True
    )
    
    # Approval workflow
    status = models.CharField(max_length=20, choices=STATUS_CHOICES, default='pending')
    rejection_reason = models.TextField(blank=True, default='')
    approved_by = models.ForeignKey(
        settings.AUTH_USER_MODEL,
        on_delete=models.SET_NULL,
        null=True,
        blank=True,
        related_name='approved_clubs'
    )
    approved_at = models.DateTimeField(null=True, blank=True)
    
    is_active = models.BooleanField(default=True)
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)
    
    class Meta:
        db_table = 'clubs'
        ordering = ['-created_at']
    
    def __str__(self):
        return f"{self.name} ({self.status})"
    
    @property
    def member_count(self):
        return self.members.count()


class ClubAdminRequest(models.Model):
    """
    Tracks pending club creation requests.
    Not strictly needed if we use Club.status, but useful for analytics.
    """
    pass  # We'll use Club.status instead