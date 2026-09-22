import 'package:flutter/foundation.dart' show kIsWeb;

class ApiConfig {
  // ═══════════════════════════════════════════════════════════
  // PRODUCTION URL (Render)
  // ═══════════════════════════════════════════════════════════
  static const String _prodUrl = 'https://campus-connect-backend-r530.onrender.com/api';

  static String get baseUrl => _prodUrl;

  // ═══════════════════════════════════════════════════════════
  // AUTH ENDPOINTS
  // ═══════════════════════════════════════════════════════════
  static const String login = '/auth/login/';
  static const String register = '/auth/register/';
  static const String profile = '/auth/profile/';
  static const String users = '/auth/users/';

  // ═══════════════════════════════════════════════════════════
  // CLUB ENDPOINTS
  // ═══════════════════════════════════════════════════════════
  static const String clubs = '/clubs/';
  static const String myClubs = '/clubs/my_clubs/';
  static String clubDetail(int id) => '/clubs/$id/';
  static String joinClub(int id) => '/clubs/$id/join/';
  static String leaveClub(int id) => '/clubs/$id/leave/';

  // ═══════════════════════════════════════════════════════════
  // EVENT ENDPOINTS
  // ═══════════════════════════════════════════════════════════
  static const String events = '/events/';
  static const String myEvents = '/events/my_events/';
  static String eventDetail(int id) => '/events/$id/';
  static String registerEvent(int id) => '/events/$id/register/';
  static String cancelEvent(int id) => '/events/$id/cancel_registration/';

  // ═══════════════════════════════════════════════════════════
  // REGISTRATION ENDPOINTS
  // ═══════════════════════════════════════════════════════════
  static const String registrations = '/registrations/';

  // ═══════════════════════════════════════════════════════════
  // NOTIFICATIONS
  // ═══════════════════════════════════════════════════════════
  static const String notifications = '/notifications/';
  static const String unreadCount = '/notifications/unread_count/';
}