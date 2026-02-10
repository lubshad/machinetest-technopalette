from django.contrib import admin
from .models import UserProfile


@admin.register(UserProfile)
class UserProfileAdmin(admin.ModelAdmin):
    list_display = [
        'user',
        'height',
        'weight',
        'city',
        'state',
        'country',
        'created_at',
        'updated_at',
    ]
    list_filter = ['family_type', 'family_status', 'country', 'state', 'created_at']
    search_fields = [
        'user__username',
        'user__email',
        'user__first_name',
        'user__last_name',
        'city',
        'state',
        'country',
        'father_name',
        'mother_name',
    ]
    readonly_fields = ['created_at', 'updated_at']
    
    fieldsets = (
        ('User', {
            'fields': ('user',)
        }),
        ('Photo', {
            'fields': ('photo',)
        }),
        ('Physical Attributes', {
            'fields': ('height', 'weight')
        }),
        ('Address & Residence', {
            'fields': (
                'address_line1',
                'address_line2',
                'city',
                'state',
                'country',
                'postal_code',
            )
        }),
        ('Family Information', {
            'fields': (
                'father_name',
                'mother_name',
                'siblings',
                'family_type',
                'family_status',
            )
        }),
        ('Bio', {
            'fields': ('bio',)
        }),
        ('Timestamps', {
            'fields': ('created_at', 'updated_at'),
            'classes': ('collapse',)
        }),
    )
