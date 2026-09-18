from django.contrib import admin
from django.contrib.auth.admin import UserAdmin
from .models import User
from .models import Notification

@admin.register(User)
class CustomUserAdmin(UserAdmin):
    list_display = [
        'username', 'email', 'first_name', 'last_name',
        'role', 'department', 'year', 'is_active'
    ]
    list_filter = ['role', 'department', 'year', 'is_active', 'is_staff']
    search_fields = ['username', 'email', 'first_name', 'last_name']
    ordering = ['-date_joined']
    
    fieldsets = UserAdmin.fieldsets + (
        ('Additional Info', {
            'fields': (
                'profile_pic', 'department', 'year',
                'skills', 'interests', 'role',
                'achievements', 'phone_number'
            )
        }),
    )
    
    add_fieldsets = UserAdmin.add_fieldsets + (
        ('Additional Info', {
            'fields': (
                'email', 'first_name', 'last_name',
                'role', 'department', 'year'
            )
        }),
    )
@admin.register(Notification)
class NotificationAdmin(admin.ModelAdmin):
    list_display = ['user', 'title', 'type', 'is_read', 'created_at']
    list_filter = ['type', 'is_read', 'created_at']
    search_fields = ['user__username', 'title', 'message']
    readonly_fields = ['created_at']
    ordering = ['-created_at']    