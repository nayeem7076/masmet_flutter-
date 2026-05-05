import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../constants/app_constants.dart';
import 'api_config.dart';

class ApiException implements Exception {
  final int? statusCode;
  final String message;

  ApiException(this.message, {this.statusCode});

  @override
  String toString() => message;
}

class ApiClient {
  static http.Client _client = http.Client();
  static Future<String?> Function()? _tokenProvider;
  static Future<bool> Function()? _onUnauthorized;

  static void configure({
    Future<String?> Function()? tokenProvider,
    Future<bool> Function()? onUnauthorized,
  }) {
    _tokenProvider = tokenProvider;
    _onUnauthorized = onUnauthorized;
  }

  static void setTestClient(http.Client client) {
    _client = client;
  }

  static Future<Map<String, dynamic>> get(
    String path, {
    Map<String, String>? headers,
    bool requiresAuth = true,
  }) {
    return _request(
      'GET',
      path,
      headers: headers,
      requiresAuth: requiresAuth,
    );
  }

  static Future<Map<String, dynamic>> post(
    String path, {
    Map<String, dynamic>? body,
    Map<String, String>? headers,
    bool requiresAuth = true,
  }) {
    return _request(
      'POST',
      path,
      body: body,
      headers: headers,
      requiresAuth: requiresAuth,
    );
  }

  static Future<Map<String, dynamic>> put(
    String path, {
    Map<String, dynamic>? body,
    Map<String, String>? headers,
    bool requiresAuth = true,
  }) {
    return _request(
      'PUT',
      path,
      body: body,
      headers: headers,
      requiresAuth: requiresAuth,
    );
  }

  static Future<Map<String, dynamic>> patch(
    String path, {
    Map<String, dynamic>? body,
    Map<String, String>? headers,
    bool requiresAuth = true,
  }) {
    return _request(
      'PATCH',
      path,
      body: body,
      headers: headers,
      requiresAuth: requiresAuth,
    );
  }

  static Future<Map<String, dynamic>> delete(
    String path, {
    Map<String, dynamic>? body,
    Map<String, String>? headers,
    bool requiresAuth = true,
  }) {
    return _request(
      'DELETE',
      path,
      body: body,
      headers: headers,
      requiresAuth: requiresAuth,
    );
  }

  static Future<Map<String, dynamic>> postJson(
    String path, {
    Map<String, dynamic>? body,
    Map<String, String>? headers,
    bool requiresAuth = true,
  }) {
    return post(path, body: body, headers: headers, requiresAuth: requiresAuth);
  }

  static Future<Map<String, dynamic>> _request(
    String method,
    String path, {
    Map<String, dynamic>? body,
    Map<String, String>? headers,
    bool requiresAuth = true,
  }) async {
    final uri = Uri.parse('${ApiConfig.baseUrl}$path');
    _validateBaseUrl(uri);
    int attempt = 0;
    bool unauthorizedRetried = false;
    while (true) {
      final token = requiresAuth ? await _tokenProvider?.call() : null;
      final requestHeaders = <String, String>{
        'Content-Type': 'application/json',
        ...?headers,
      };
      if (requiresAuth && token != null && token.isNotEmpty) {
        requestHeaders['Authorization'] = 'Bearer $token';
      }
      try {
        final response = await _send(
          method,
          uri,
          headers: requestHeaders,
          body: body,
        ).timeout(ApiConfig.connectTimeout);

        final data = _decode(response.body);

        if (response.statusCode == 401) {
          if (!unauthorizedRetried && _onUnauthorized != null) {
            final handled = await _onUnauthorized!.call();
            if (handled) {
              unauthorizedRetried = true;
              continue;
            }
          }
          throw ApiException(
            _extractErrorMessage(data, 'Unauthorized request.'),
            statusCode: response.statusCode,
          );
        }

        if (response.statusCode < 200 || response.statusCode >= 300) {
          final message = _extractErrorMessage(
            data,
            'Request failed (${response.statusCode}).',
          );

          final isRetryableServerError = response.statusCode >= 500;
          if (isRetryableServerError && attempt < AppConstants.apiRetryCount) {
            attempt++;
            continue;
          }
          throw ApiException(message, statusCode: response.statusCode);
        }

        return _normalizeToMap(data);
      } on TimeoutException {
        if (attempt < AppConstants.apiRetryCount) {
          attempt++;
          continue;
        }
        throw ApiException(
          'Request timeout for ${uri.toString()}. '
          'Use your PC LAN IP in API_BASE_URL (example: http://192.168.x.x:8001).',
        );
      } on http.ClientException {
        if (attempt < AppConstants.apiRetryCount) {
          attempt++;
          continue;
        }
        throw ApiException('Network error. Please check your internet/server.');
      }
    }
  }

  static Future<http.Response> _send(
    String method,
    Uri uri, {
    required Map<String, String> headers,
    Map<String, dynamic>? body,
  }) {
    final encodedBody = body == null ? null : jsonEncode(body);
    switch (method) {
      case 'GET':
        return _client.get(uri, headers: headers);
      case 'POST':
        return _client.post(uri, headers: headers, body: encodedBody);
      case 'PUT':
        return _client.put(uri, headers: headers, body: encodedBody);
      case 'PATCH':
        return _client.patch(uri, headers: headers, body: encodedBody);
      case 'DELETE':
        return _client.delete(uri, headers: headers, body: encodedBody);
      default:
        throw ApiException('Unsupported HTTP method: $method');
    }
  }

  static dynamic _decode(String body) {
    if (body.isEmpty) return <String, dynamic>{};
    try {
      return jsonDecode(body);
    } catch (_) {
      return <String, dynamic>{'message': body};
    }
  }

  static String _extractErrorMessage(dynamic data, String fallback) {
    if (data is Map<String, dynamic>) {
      final m = data['message'];
      if (m is String && m.trim().isNotEmpty) return m;
      final e = data['error'];
      if (e is String && e.trim().isNotEmpty) return e;
    }
    return fallback;
  }

  static Map<String, dynamic> _normalizeToMap(dynamic data) {
    if (data is Map<String, dynamic>) return data;
    return <String, dynamic>{'data': data};
  }

  static void _validateBaseUrl(Uri uri) {
    final host = uri.host.toLowerCase();
    if (host == '127.0.0.1' || host == 'localhost') {
      throw ApiException(
        'Invalid API_BASE_URL for phone: ${ApiConfig.baseUrl}. '
        'Use LAN IP (http://192.168.x.x:8001) or emulator host (http://10.0.2.2:8001).',
      );
    }
  }
}
