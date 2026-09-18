from django.contrib import admin
from django.utils.html import format_html
from .models import Club


@admin.register(Club)
class ClubAdmin(admin.ModelAdmin):
    list_display = [
        'name', 'category', 'status_badge', 'coordinator',
        'member_count_display', 'created_at'
    ]
    list_filter = ['status', 'category', 'is_active', 'created_at']
    search_fields = ['name', 'description']
    filter_horizontal = ['members']
    readonly_fields = ['created_at', 'updated_at', 'approved_at']
    
    fieldsets = (
        ('Club Information', {
            'fields': ('name', 'description', 'category', 'logo')
        }),
        ('Management', {
            'fields': ('coordinator', 'created_by', 'members', 'is_active')
        }),
        ('Approval', {
            'fields': ('status', 'rejection_reason', 'approved_by', 'approved_at')
        }),
        ('Timestamps', {
            'fields': ('created_at', 'updated_at'),
            'classes': ('collapse',)
        }),
    )
    
    actions = ['approve_clubs', 'reject_clubs']
    
    def status_badge(self, obj):
        colors = {
            'pending': '#FFA500',
            'approved': '#28a745',
            'rejected': '#dc3545',
        }
        color = colors.get(obj.status, '#6c757d')
        return format_html(
            '<span style="background-color: {}; color: white; '
            'padding: 3px 10px; border-radius: 12px; font-size: 11px;">{}</span>',
            color,
            obj.status.upper()
        )
    status_badge.short_description = 'Status'
    
    def member_count_display(self, obj):
        return obj.members.count()
    member_count_display.short_description = 'Members'
    
    @admin.action(description='✅ Approve selected clubs')
    def approve_clubs(self, request, queryset):
        from django.utils import timezone
        from accounts.models import Notification
        
        for club in queryset:
            club.status = 'approved'
            club.approved_by = request.user
            club.approved_at = timezone.now()
            club.save()
            
            if club.created_by:
                Notification.objects.create(
                    user=club.created_by,
                    title='Club Approved! 🎉',
                    message=f'Your club "{club.name}" has been approved.',
                    type='club_approved',
                    related_club=club,
                )
        
        self.message_user(request, f'{queryset.count()} clubs approved.')
    
    @admin.action(description='❌ Reject selected clubs')
    def reject_clubs(self, request, queryset):
        from django.utils import timezone
        from accounts.models import Notification
        
        for club in queryset:
            club.status = 'rejected'
            club.approved_by = request.user
            club.approved_at = timezone.now()
            club.save()
            
            if club.created_by:
                Notification.objects.create(
                    user=club.created_by,
                    title='Club Request Rejected',
                    message=f'Your request to create "{club.name}" was rejected.',
                    type='club_rejected',
                    related_club=club,
                )
        
        self.message_user(request, f'{queryset.count()} clubs rejected.')