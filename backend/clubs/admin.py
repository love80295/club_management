from django.contrib import admin
from .models import Club


@admin.register(Club)
class ClubAdmin(admin.ModelAdmin):
    list_display = [
        'name', 'category', 'coordinator',
        'member_count_display', 'is_active', 'created_at'
    ]
    list_filter = ['category', 'is_active']
    search_fields = ['name', 'description']
    filter_horizontal = ['members']
    readonly_fields = ['created_at', 'updated_at', 'member_count_display']
    
    fieldsets = (
        ('Club Information', {
            'fields': ('name', 'description', 'category', 'logo')
        }),
        ('Management', {
            'fields': ('coordinator', 'members', 'member_count_display', 'is_active')
        }),
        ('Timestamps', {
            'fields': ('created_at', 'updated_at'),
            'classes': ('collapse',)
        }),
    )
    
    def member_count_display(self, obj):
        """Display member count"""
        return obj.members.count()
    member_count_display.short_description = 'Members'