import '../models/club_model.dart';
import '../config/api_config.dart';
import 'api_service.dart';

class ClubService {
  // ═══════════════════════════════════════════════════════════
  // GET ALL CLUBS
  // ═══════════════════════════════════════════════════════════
  static Future<Map<String, dynamic>> getAllClubs({
    String? search,
    String? category,
  }) async {
    String endpoint = ApiConfig.clubs;
    final queryParams = <String>[];
    if (search != null && search.isNotEmpty) queryParams.add('search=$search');
    if (category != null && category.isNotEmpty && category != 'All') {
      queryParams.add('category=$category');
    }
    if (queryParams.isNotEmpty) endpoint += '?${queryParams.join('&')}';

    final response = await ApiService.get(endpoint);

    if (response['success'] == true) {
      List<Club> clubs = [];
      if (response['results'] != null) {
        clubs = (response['results'] as List)
            .map((json) => Club.fromJson(json))
            .toList();
      } else if (response['data'] != null) {
        clubs = (response['data'] as List)
            .map((json) => Club.fromJson(json))
            .toList();
      }
      return {'success': true, 'clubs': clubs, 'count': response['count'] ?? clubs.length};
    }

    return {'success': false, 'message': response['message'] ?? 'Failed to load clubs'};
  }

  // ═══════════════════════════════════════════════════════════
  // GET CLUB DETAIL
  // ═══════════════════════════════════════════════════════════
  static Future<Map<String, dynamic>> getClubDetail(int clubId) async {
    final response = await ApiService.get(ApiConfig.clubDetail(clubId));

    if (response['success'] == true) {
      return {
        'success': true,
        'club': Club.fromJson(response),
        'raw': response,
      };
    }

    return {'success': false, 'message': response['message'] ?? 'Failed to load club'};
  }

  // ═══════════════════════════════════════════════════════════
  // JOIN CLUB
  // ═══════════════════════════════════════════════════════════
  static Future<Map<String, dynamic>> joinClub(int clubId) async {
    final response = await ApiService.post(ApiConfig.joinClub(clubId), {});
    return {
      'success': response['success'] == true,
      'message': response['message'] ?? response['detail'] ??
          (response['success'] == true ? 'Joined!' : 'Failed to join'),
    };
  }

  // ═══════════════════════════════════════════════════════════
  // LEAVE CLUB
  // ═══════════════════════════════════════════════════════════
  static Future<Map<String, dynamic>> leaveClub(int clubId) async {
    final response = await ApiService.post(ApiConfig.leaveClub(clubId), {});
    return {
      'success': response['success'] == true,
      'message': response['message'] ?? response['detail'] ??
          (response['success'] == true ? 'Left!' : 'Failed to leave'),
    };
  }

  // ═══════════════════════════════════════════════════════════
  // GET MY CLUBS
  // ═══════════════════════════════════════════════════════════
  static Future<Map<String, dynamic>> getMyClubs() async {
    final response = await ApiService.get(ApiConfig.myClubs);
    if (response['success'] == true) {
      List<Club> clubs = [];
      if (response['data'] != null) {
        clubs = (response['data'] as List).map((json) => Club.fromJson(json)).toList();
      } else if (response['results'] != null) {
        clubs = (response['results'] as List).map((json) => Club.fromJson(json)).toList();
      }
      return {'success': true, 'clubs': clubs};
    }
    return {'success': false, 'message': response['message'] ?? 'Failed to load my clubs'};
  }

  // ═══════════════════════════════════════════════════════════
  // CREATE CLUB (Request) - WITH IMAGE
  // ═══════════════════════════════════════════════════════════
  static Future<Map<String, dynamic>> createClub({
    required String name,
    required String description,
    required String category,
    required String instagramHandle,
    required String clubEmail,
    String? logoPath,
  }) async {
    final data = {
      'name': name,
      'description': description,
      'category': category,
      'instagram_handle': instagramHandle,
      'club_email': clubEmail,
    };

    final response = await ApiService.postMultipart(
      ApiConfig.clubs,
      data,
      filePath: logoPath,
      fileField: 'logo',
    );

    if (response['success'] == true) {
      return {
        'success': true,
        'club': Club.fromJson(response['club'] ?? {}),
        'message': response['detail'] ?? 'Club creation request submitted!',
      };
    }

    if (response['statusCode'] == 400 &&
        response['message'] != null &&
        response['message'].toString().toLowerCase().contains('already manage')) {
      return {
        'success': false,
        'alreadyHasClub': true,
        'existingClub': response['existing_club'],
        'message': 'You cannot create another club. Please contact the head.',
      };
    }

    return {
      'success': false,
      'message': response['message'] ?? response['detail'] ?? 'Failed to create club',
    };
  }

  // ═══════════════════════════════════════════════════════════
  // CREATE EVENT (Coordinator) - WITH IMAGE
  // ═══════════════════════════════════════════════════════════
  static Future<Map<String, dynamic>> createEvent({
    required int clubId,
    required String title,
    required String description,
    required String date,
    required String time,
    required String venue,
    required String category,
    required int maxParticipants,
    String? imagePath,
  }) async {
    final data = {
      'club': clubId.toString(),
      'title': title,
      'description': description,
      'date': date,
      'time': time,
      'venue': venue,
      'category': category,
      'max_participants': maxParticipants.toString(),
    };

    final response = await ApiService.postMultipart(
      ApiConfig.events,
      data,
      filePath: imagePath,
      fileField: 'image',
    );

    if (response['success'] == true) {
      return {'success': true, 'message': 'Event created successfully', 'data': response};
    }

    return {
      'success': false,
      'message': response['message'] ?? response['detail'] ?? 'Failed to create event',
    };
  }

  // ═══════════════════════════════════════════════════════════
  // KICK MEMBER
  // ═══════════════════════════════════════════════════════════
  static Future<Map<String, dynamic>> kickMember({
    required int clubId,
    required int userId,
  }) async {
    final response = await ApiService.post(
      '/clubs/$clubId/kick_member/',
      {'user_id': userId},
    );
    return {
      'success': response['success'] == true,
      'message': response['detail'] ?? response['message'] ?? 'Action completed',
    };
  }

  // ═══════════════════════════════════════════════════════════
  // GET MY MANAGED CLUB
  // ═══════════════════════════════════════════════════════════
  static Future<Map<String, dynamic>> getMyManagedClub() async {
    final response = await ApiService.get('/clubs/my_managed_club/');
    if (response['success'] == true) {
      final clubData = response['club'];
      return {
        'success': true,
        'club': clubData != null ? Club.fromJson(clubData) : null,
      };
    }
    return {'success': false, 'message': response['message'], 'club': null};
  }
}