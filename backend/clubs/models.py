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
    
    name = models.CharField(max_length=100, unique=True)
    description = models.TextField()
    logo = models.ImageField(upload_to='clubs/', null=True, blank=True)
    category = models.CharField(max_length=50, choices=CATEGORIES)
    coordinator = models.ForeignKey(
        settings.AUTH_USER_MODEL,
        on_delete=models.SET_NULL,
        null=True,
        related_name='coordinated_clubs'
    )
    members = models.ManyToManyField(
        settings.AUTH_USER_MODEL,
        related_name='joined_clubs',
        blank=True
    )
    is_active = models.BooleanField(default=True)
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)
    
    class Meta:
        db_table = 'clubs'
        ordering = ['name']
    
    def __str__(self):
        return self.name
    
    @property
    def member_count(self):
        return self.members.count()