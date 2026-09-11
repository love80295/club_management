from django.db import models
from django.conf import settings
from django.utils import timezone

class Event(models.Model):
    CATEGORIES = (
        ('Event', 'Event'),
        ('Workshop', 'Workshop'),
        ('Hackathon', 'Hackathon'),
        ('Club Activity', 'Club Activity'),
    )
    
    title = models.CharField(max_length=200)
    description = models.TextField()
    date = models.DateField()
    time = models.TimeField()
    venue = models.CharField(max_length=200)
    category = models.CharField(max_length=50, choices=CATEGORIES)
    club = models.ForeignKey(
        'clubs.Club',
        on_delete=models.CASCADE,
        related_name='events'
    )
    organizer_name = models.CharField(max_length=100)
    max_participants = models.PositiveIntegerField(default=50)
    registered_users = models.ManyToManyField(
        settings.AUTH_USER_MODEL,
        related_name='registered_events',
        blank=True
    )
    image = models.ImageField(upload_to='events/', null=True, blank=True)
    is_past = models.BooleanField(default=False)
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)
    
    class Meta:
        db_table = 'events'
        ordering = ['date', 'time']
    
    def __str__(self):
        return self.title
    
    @property
    def available_spots(self):
        return self.max_participants - self.registered_users.count()
    
    @property
    def is_full(self):
        return self.registered_users.count() >= self.max_participants