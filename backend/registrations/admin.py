from django.contrib import admin
from .models import Registration


@admin.register(Registration)
class RegistrationAdmin(admin.ModelAdmin):
    list_display = [
        'user', 'event', 'status',
        'registered_at', 'is_checked_in', 'checked_in_at'
    ]
    list_filter = ['status', 'is_checked_in']
    search_fields = ['user__username', 'event__title']
    readonly_fields = ['registered_at', 'updated_at', 'qr_code']
    
    fieldsets = (
        ('Registration Info', {
            'fields': ('user', 'event', 'status')
        }),
        ('Check-In', {
            'fields': ('is_checked_in', 'checked_in_at', 'qr_code')
        }),
        ('Timestamps', {
            'fields': ('registered_at', 'updated_at'),
            'classes': ('collapse',)
        }),
    )