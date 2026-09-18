import 'api_service.dart';

class NotificationService {
  // ═══════════════════════════════════════════════════════════
  // GET ALL NOTIFICATIONS
  // ═══════════════════════════════════════════════════════════
  static Future<Map<String, dynamic>> getNotifications() async {
    final response = await ApiService.get('/notifications/');

    if (response['success'] == true) {
      List<Map<String, dynamic>> notifications = [];
      
      if (response['results'] != null) {
        notifications = List<Map<String, dynamic>>.from(response['results']);
      } else if (response['data'] != null) {
        notifications = List<Map<String, dynamic>>.from(response['data']);
      }

      return {
        'success': true,
        'notifications': notifications,
      };
    }

    return {
      'success': false,
      'message': response['message'] ?? 'Failed to load notifications',
      'notifications': [],
    };
  }

  // ═══════════════════════════════════════════════════════════
  // GET UNREAD COUNT (For Bell Badge)
  // ═══════════════════════════════════════════════════════════
  static Future<int> getUnreadCount() async {
    final response = await ApiService.get('/notifications/unread_count/');

    if (response['success'] == true) {
      return response['count'] ?? 0;
    }
    return 0;
  }

  // ═══════════════════════════════════════════════════════════
  // MARK ONE AS READ
  // ═══════════════════════════════════════════════════════════
  static Future<Map<String, dynamic>> markAsRead(int notificationId) async {
    final response = await ApiService.post(
      '/notifications/$notificationId/mark_read/',
      {},
    );

    return {
      'success': response['success'] == true,
      'message': response['detail'] ?? 'Marked as read',
    };
  }

  // ═══════════════════════════════════════════════════════════
  // MARK ALL AS READ
  // ═══════════════════════════════════════════════════════════
  static Future<Map<String, dynamic>> markAllAsRead() async {
    final response = await ApiService.post(
      '/notifications/mark_all_read/',
      {},
    );

    return {
      'success': response['success'] == true,
      'message': response['detail'] ?? 'All notifications marked as read',
    };
  }
}