from django.contrib import admin
from .models import Event


@admin.register(Event)
class EventAdmin(admin.ModelAdmin):
    list_display = [
        'title', 'club', 'date', 'time',
        'venue', 'category', 'registered_count_display', 'is_past'
    ]
    list_filter = ['category', 'is_past', 'date', 'club']
    search_fields = ['title', 'description', 'venue']
    filter_horizontal = ['registered_users']
    readonly_fields = ['created_at', 'updated_at', 'registered_count_display', 'available_spots']
    
    fieldsets = (
        ('Event Information', {
            'fields': ('title', 'description', 'category', 'image')
        }),
        ('Schedule', {
            'fields': ('date', 'time', 'venue', 'is_past')
        }),
        ('Organizer', {
            'fields': ('club', 'organizer_name')
        }),
        ('Participants', {
            'fields': ('max_participants', 'registered_users', 'registered_count_display', 'available_spots')
        }),
        ('Timestamps', {
            'fields': ('created_at', 'updated_at'),
            'classes': ('collapse',)
        }),
    )
    
    def registered_count_display(self, obj):
        """Display registered count with max participants"""
        return f"{obj.registered_users.count()}/{obj.max_participants}"
    registered_count_display.short_description = 'Registered'
    
    def available_spots(self, obj):
        """Display available spots"""
        return obj.max_participants - obj.registered_users.count()
    available_spots.short_description = 'Available Spots'