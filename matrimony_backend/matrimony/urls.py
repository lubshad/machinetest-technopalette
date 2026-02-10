"""
URL configuration for matrimony project.

The `urlpatterns` list routes URLs to views. For more information please see:
    https://docs.djangoproject.com/en/4.2/topics/http/urls/
"""
from django.urls import path, include
from django.http import JsonResponse
from django.contrib import admin


def health_check(request):
    """Health check endpoint for monitoring."""
    return JsonResponse({'status': 'healthy', 'service': 'matrimony'})


urlpatterns = [
    # path('admin/', admin.site.urls),
    path('health/', health_check, name='health_check'),
    path('api/auth/', include('authentication.urls')),
    path('api/', include('user_profile.urls')),
]
