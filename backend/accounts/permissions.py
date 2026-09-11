from rest_framework import permissions


class IsAdminUser(permissions.BasePermission):
    """
    Permission to only allow admin users (superuser or role='admin')
    """
    def has_permission(self, request, view):
        return (
            request.user and
            request.user.is_authenticated and
            (request.user.is_superuser or request.user.role == 'admin')
        )


class IsClubAdmin(permissions.BasePermission):
    """
    Permission to allow club admins or superusers
    """
    def has_permission(self, request, view):
        return (
            request.user and
            request.user.is_authenticated and
            (request.user.is_superuser or 
             request.user.role in ['admin', 'club_admin'])
        )


class IsOwnerOrAdmin(permissions.BasePermission):
    """
    Permission to allow owners or admins
    """
    def has_object_permission(self, request, view, obj):
        if request.user.is_superuser or request.user.role == 'admin':
            return True
        return obj.coordinator == request.user or obj.user == request.user


class IsStudent(permissions.BasePermission):
    """
    Permission to only allow students
    """
    def has_permission(self, request, view):
        return (
            request.user and
            request.user.is_authenticated and
            request.user.role == 'student'
        )