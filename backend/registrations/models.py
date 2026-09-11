from django.db import models
from django.conf import settings
from django.utils import timezone
import uuid

class Registration(models.Model):
    STATUS_CHOICES = (
        ('Confirmed', 'Confirmed'),
        ('Pending', 'Pending'),
        ('Completed', 'Completed'),
        ('Cancelled', 'Cancelled'),
    )
    
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    user = models.ForeignKey(
        settings.AUTH_USER_MODEL,
        on_delete=models.CASCADE,
        related_name='registrations'
    )
    event = models.ForeignKey(
        'events.Event',
        on_delete=models.CASCADE,
        related_name='registrations'
    )
    status = models.CharField(
        max_length=20,
        choices=STATUS_CHOICES,
        default='Pending'
    )
    registered_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)
    is_checked_in = models.BooleanField(default=False)
    checked_in_at = models.DateTimeField(null=True, blank=True)
    qr_code = models.CharField(max_length=255, blank=True, null=True)
    
    class Meta:
        db_table = 'registrations'
        ordering = ['-registered_at']
        unique_together = ['user', 'event']
    
    def __str__(self):
        return f"{self.user.username} - {self.event.title}"
    
    def save(self, *args, **kwargs):
        if not self.qr_code:
            self.qr_code = f"CC-{self.user.id}-{self.event.id}-{uuid.uuid4().hex[:6].upper()}"
        super().save(*args, **kwargs)