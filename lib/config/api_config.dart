import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;

class ApiConfig {
  // ═══════════════════════════════════════════════════════════
  // BASE URL - Automatically detected based on platform
  // ═══════════════════════════════════════════════════════════
  //
  // • Web / iOS Simulator: http://127.0.0.1:8000/api
  // • Android Emulator:    http://10.0.2.2:8000/api
  // • Physical Device:     http://YOUR_MAC_IP:8000/api
  // ═══════════════════════════════════════════════════════════

  static String get baseUrl {
    if (kIsWeb) {
      return 'http://127.0.0.1:8000/api';
    } else if (Platform.isAndroid) {
      return 'http://10.0.2.2:8000/api';
    } else if (Platform.isIOS) {
      return 'http://127.0.0.1:8000/api';
    }
    return 'http://127.0.0.1:8000/api';
  }

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
}