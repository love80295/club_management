"""
Vercel serverless entry point for Django backend.
"""
import os
import sys

# Add backend directory to Python path
sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

# Set Django settings
os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'club_backend.settings')

# Get WSGI application
from django.core.wsgi import get_wsgi_application

app = get_wsgi_application()

# Vercel handler
handler = app