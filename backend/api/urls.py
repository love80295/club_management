from django.urls import path, include
from rest_framework.routers import DefaultRouter
from .views import ClubViewSet, EventViewSet, RegistrationViewSet

router = DefaultRouter()
router.register(r'clubs', ClubViewSet, basename='club')
router.register(r'events', EventViewSet, basename='event')
router.register(r'registrations', RegistrationViewSet, basename='registration')

urlpatterns = [
    path('', include(router.urls)),
]