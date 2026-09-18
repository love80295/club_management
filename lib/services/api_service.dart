import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../config/api_config.dart';

class ApiService {
  // ═══════════════════════════════════════════════════════════
  // HEADERS
  // ═══════════════════════════════════════════════════════════
  static Future<Map<String, String>> getHeaders({bool auth = true}) async {
    final Map<String, String> headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    if (auth) {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('access_token');
      if (token != null && token.isNotEmpty) {
        headers['Authorization'] = 'Bearer $token';
      }
    }

    return headers;
  }

  // ═══════════════════════════════════════════════════════════
  // GET
  // ═══════════════════════════════════════════════════════════
  static Future<Map<String, dynamic>> get(
    String endpoint, {
    bool auth = true,
  }) async {
    try {
      final url = Uri.parse('${ApiConfig.baseUrl}$endpoint');
      final headers = await getHeaders(auth: auth);

      print('🌐 GET: $url');
      final response = await http.get(url, headers: headers);
      print('📥 Status: ${response.statusCode}');

      return _handleResponse(response);
    } catch (e) {
      print('❌ GET Error: $e');
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  // ═══════════════════════════════════════════════════════════
  // POST (JSON)
  // ═══════════════════════════════════════════════════════════
  static Future<Map<String, dynamic>> post(
    String endpoint,
    Map<String, dynamic> data, {
    bool auth = true,
  }) async {
    try {
      final url = Uri.parse('${ApiConfig.baseUrl}$endpoint');
      final headers = await getHeaders(auth: auth);

      print('🌐 POST: $url');
      final response = await http.post(
        url,
        headers: headers,
        body: jsonEncode(data),
      );

      print('📥 Status: ${response.statusCode}');
      return _handleResponse(response);
    } catch (e) {
      print('❌ POST Error: $e');
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  // ═══════════════════════════════════════════════════════════
  // POST MULTIPART (With image/file)
  // ═══════════════════════════════════════════════════════════
  static Future<Map<String, dynamic>> postMultipart(
    String endpoint,
    Map<String, dynamic> data, {
    String? filePath,
    String fileField = 'file',
    bool auth = true,
  }) async {
    try {
      final url = Uri.parse('${ApiConfig.baseUrl}$endpoint');
      final headers = await getHeaders(auth: auth);
      headers.remove('Content-Type');

      final request = http.MultipartRequest('POST', url);
      request.headers.addAll(headers);

      // Add text fields
      data.forEach((key, value) {
        request.fields[key] = value.toString();
      });

      // Add file if provided
      if (filePath != null && filePath.isNotEmpty) {
        final file = File(filePath);
        if (await file.exists()) {
          final ext = filePath.split('.').last.toLowerCase();
          final mimeType = _getMimeType(ext);

          final multipartFile = await http.MultipartFile.fromPath(
            fileField,
            filePath,
            contentType: MediaType.parse(mimeType),
          );
          request.files.add(multipartFile);
        }
      }

      print('🌐 POST MULTIPART: $url');
      print('📤 Fields: $data');

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      print('📥 Status: ${response.statusCode}');
      return _handleResponse(response);
    } catch (e) {
      print('❌ POST MULTIPART Error: $e');
      return {'success': false, 'message': 'Upload error: $e'};
    }
  }

  // ═══════════════════════════════════════════════════════════
  // PUT
  // ═══════════════════════════════════════════════════════════
  static Future<Map<String, dynamic>> put(
    String endpoint,
    Map<String, dynamic> data, {
    bool auth = true,
  }) async {
    try {
      final url = Uri.parse('${ApiConfig.baseUrl}$endpoint');
      final headers = await getHeaders(auth: auth);

      print('🌐 PUT: $url');
      final response = await http.put(
        url,
        headers: headers,
        body: jsonEncode(data),
      );

      print('📥 Status: ${response.statusCode}');
      return _handleResponse(response);
    } catch (e) {
      print('❌ PUT Error: $e');
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  // ═══════════════════════════════════════════════════════════
  // PUT MULTIPART
  // ═══════════════════════════════════════════════════════════
  static Future<Map<String, dynamic>> putMultipart(
    String endpoint,
    Map<String, dynamic> data, {
    String? filePath,
    String fileField = 'file',
    bool auth = true,
  }) async {
    try {
      final url = Uri.parse('${ApiConfig.baseUrl}$endpoint');
      final headers = await getHeaders(auth: auth);
      headers.remove('Content-Type');

      final request = http.MultipartRequest('PUT', url);
      request.headers.addAll(headers);

      data.forEach((key, value) {
        request.fields[key] = value.toString();
      });

      if (filePath != null && filePath.isNotEmpty) {
        final file = File(filePath);
        if (await file.exists()) {
          final ext = filePath.split('.').last.toLowerCase();
          final multipartFile = await http.MultipartFile.fromPath(
            fileField,
            filePath,
            contentType: MediaType.parse(_getMimeType(ext)),
          );
          request.files.add(multipartFile);
        }
      }

      print('🌐 PUT MULTIPART: $url');

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      print('📥 Status: ${response.statusCode}');
      return _handleResponse(response);
    } catch (e) {
      print('❌ PUT MULTIPART Error: $e');
      return {'success': false, 'message': 'Upload error: $e'};
    }
  }

  // ═══════════════════════════════════════════════════════════
  // DELETE
  // ═══════════════════════════════════════════════════════════
  static Future<Map<String, dynamic>> delete(
    String endpoint, {
    bool auth = true,
  }) async {
    try {
      final url = Uri.parse('${ApiConfig.baseUrl}$endpoint');
      final headers = await getHeaders(auth: auth);

      print('🌐 DELETE: $url');
      final response = await http.delete(url, headers: headers);
      print('📥 Status: ${response.statusCode}');

      return _handleResponse(response);
    } catch (e) {
      print('❌ DELETE Error: $e');
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  // ═══════════════════════════════════════════════════════════
  // RESPONSE HANDLER
  // ═══════════════════════════════════════════════════════════
  static Map<String, dynamic> _handleResponse(http.Response response) {
    final statusCode = response.statusCode;

    if (statusCode >= 200 && statusCode < 300) {
      if (response.body.isEmpty) return {'success': true};
      try {
        final decoded = jsonDecode(response.body);
        if (decoded is Map<String, dynamic>) {
          return {'success': true, ...decoded};
        }
        return {'success': true, 'data': decoded};
      } catch (e) {
        return {'success': true, 'data': response.body};
      }
    }

    if (statusCode == 401) {
      return {
        'success': false,
        'statusCode': 401,
        'message': 'Session expired. Please login again.',
      };
    }

    try {
      final decoded = jsonDecode(response.body);
      return {
        'success': false,
        'statusCode': statusCode,
        'message': _extractErrorMessage(decoded),
        'errors': decoded,
      };
    } catch (e) {
      return {
        'success': false,
        'statusCode': statusCode,
        'message': 'Error: $statusCode',
      };
    }
  }

  static String _extractErrorMessage(dynamic decoded) {
    if (decoded is Map<String, dynamic>) {
      if (decoded.containsKey('detail')) return decoded['detail'].toString();
      if (decoded.containsKey('message')) return decoded['message'].toString();
      for (var entry in decoded.entries) {
        if (entry.value is List) {
          return '${entry.key}: ${(entry.value as List).first}';
        }
        return '${entry.key}: ${entry.value}';
      }
    }
    return 'Something went wrong';
  }

  static String _getMimeType(String ext) {
    switch (ext) {
      case 'jpg':
      case 'jpeg':
        return 'image/jpeg';
      case 'png':
        return 'image/png';
      case 'gif':
        return 'image/gif';
      case 'webp':
        return 'image/webp';
      default:
        return 'application/octet-stream';
    }
  }

  // ═══════════════════════════════════════════════════════════
  // TOKEN MANAGEMENT
  // ═══════════════════════════════════════════════════════════
  static Future<void> saveTokens(String access, String refresh) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('access_token', access);
    await prefs.setString('refresh_token', refresh);
  }

  static Future<String?> getAccessToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('access_token');
  }

  static Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access_token');
    return token != null && token.isNotEmpty;
  }

  static Future<void> clearTokens() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('access_token');
    await prefs.remove('refresh_token');
    await prefs.remove('user_data');
  }
}