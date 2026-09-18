import '../models/event_model.dart';
import '../config/api_config.dart';
import 'api_service.dart';

class EventService {
  // ═══════════════════════════════════════════════════════════
  // GET ALL EVENTS
  // ═══════════════════════════════════════════════════════════
  static Future<Map<String, dynamic>> getAllEvents({
    String? search,
    String? category,
  }) async {
    String endpoint = ApiConfig.events;

    final queryParams = <String>[];
    if (search != null && search.isNotEmpty) {
      queryParams.add('search=$search');
    }
    if (category != null && category.isNotEmpty && category != 'All') {
      queryParams.add('category=$category');
    }
    if (queryParams.isNotEmpty) {
      endpoint += '?${queryParams.join('&')}';
    }

    final response = await ApiService.get(endpoint);

    if (response['success'] == true) {
      List<Event> events = [];
      if (response['results'] != null) {
        events = (response['results'] as List)
            .map((json) => Event.fromJson(json))
            .toList();
      } else if (response['data'] != null) {
        events = (response['data'] as List)
            .map((json) => Event.fromJson(json))
            .toList();
      }

      return {
        'success': true,
        'events': events,
        'count': response['count'] ?? events.length,
      };
    }

    return {
      'success': false,
      'message': response['message'] ?? 'Failed to load events',
    };
  }

  // ═══════════════════════════════════════════════════════════
  // GET EVENT DETAILS
  // ═══════════════════════════════════════════════════════════
  static Future<Map<String, dynamic>> getEventDetail(int eventId) async {
    final response = await ApiService.get(ApiConfig.eventDetail(eventId));

    if (response['success'] == true) {
      return {
        'success': true,
        'event': Event.fromJson(response),
      };
    }

    return {
      'success': false,
      'message': response['message'] ?? 'Failed to load event',
    };
  }

  // ═══════════════════════════════════════════════════════════
  // REGISTER FOR EVENT
  // ═══════════════════════════════════════════════════════════
  static Future<Map<String, dynamic>> registerForEvent(int eventId) async {
    final response = await ApiService.post(
      ApiConfig.registerEvent(eventId),
      {},
    );

    return {
      'success': response['success'] == true,
      'message': response['message'] ??
          response['detail'] ??
          (response['success'] == true
              ? 'Registered successfully'
              : 'Failed to register'),
    };
  }

  // ═══════════════════════════════════════════════════════════
  // CANCEL REGISTRATION
  // ═══════════════════════════════════════════════════════════
  static Future<Map<String, dynamic>> cancelRegistration(int eventId) async {
    final response = await ApiService.post(
      ApiConfig.cancelEvent(eventId),
      {},
    );

    return {
      'success': response['success'] == true,
      'message': response['message'] ??
          response['detail'] ??
          (response['success'] == true
              ? 'Registration cancelled'
              : 'Failed to cancel'),
    };
  }

  // ═══════════════════════════════════════════════════════════
  // GET MY EVENTS
  // ═══════════════════════════════════════════════════════════
  static Future<Map<String, dynamic>> getMyEvents() async {
    final response = await ApiService.get(ApiConfig.myEvents);

    if (response['success'] == true) {
      List<Event> events = [];
      if (response['data'] != null) {
        events = (response['data'] as List)
            .map((json) => Event.fromJson(json))
            .toList();
      } else if (response['results'] != null) {
        events = (response['results'] as List)
            .map((json) => Event.fromJson(json))
            .toList();
      }

      return {
        'success': true,
        'events': events,
      };
    }

    return {
      'success': false,
      'message': response['message'] ?? 'Failed to load my events',
    };
  }
}