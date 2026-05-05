import 'package:messmate_app_full/core/constants/app_constants.dart';
import 'package:messmate_app_full/core/network/api_client.dart';
import 'package:messmate_app_full/core/network/api_response.dart';
import 'package:messmate_app_full/features/auth/data/models/auth_tokens.dart';

class AuthLoginResult {
  final AuthTokens tokens;
  final String role;
  final String identifier;

  const AuthLoginResult({
    required this.tokens,
    required this.role,
    required this.identifier,
  });
}

class AuthService {
  static Future<AuthLoginResult> login({
    required String email,
    required String password,
    String role = 'member',
  }) async {
    final json = await ApiClient.post(
      ApiRoutes.login,
      body: {
        'email': email,
        'password': password,
      },
      requiresAuth: false,
    );

    final response = ApiResponse<Map<String, dynamic>>.fromJson(
      json,
      dataParser: (raw) =>
          (raw as Map?)?.cast<String, dynamic>() ?? <String, dynamic>{},
    );

    final tokens = AuthTokens.fromJson(response.data ?? json);
    if (!tokens.isValid) {
      throw ApiException('Token missing from login response.');
    }

    return AuthLoginResult(tokens: tokens, role: role, identifier: email);
  }

  static Future<AuthTokens> refreshToken(String refreshToken) async {
    final json = await ApiClient.post(
      ApiRoutes.refreshToken,
      body: {'refreshToken': refreshToken},
      requiresAuth: false,
    );

    final response = ApiResponse<Map<String, dynamic>>.fromJson(
      json,
      dataParser: (raw) =>
          (raw as Map?)?.cast<String, dynamic>() ?? <String, dynamic>{},
    );

    final tokens = AuthTokens.fromJson(response.data ?? json);
    if (!tokens.isValid) {
      throw ApiException('Token missing from refresh response.');
    }
    return tokens;
  }

  static Future<AuthLoginResult> register({
    required String name,
    required String email,
    required String password,
    required String passwordConfirmation,
    String role = 'member',
  }) async {
    final json = await ApiClient.post(
      ApiRoutes.register,
      body: {
        'name': name,
        'email': email,
        'password': password,
        'password_confirmation': passwordConfirmation,
      },
      requiresAuth: false,
    );

    final response = ApiResponse<Map<String, dynamic>>.fromJson(
      json,
      dataParser: (raw) =>
          (raw as Map?)?.cast<String, dynamic>() ?? <String, dynamic>{},
    );

    final tokens = AuthTokens.fromJson(response.data ?? json);
    if (!tokens.isValid) {
      throw ApiException('Token missing from register response.');
    }

    return AuthLoginResult(tokens: tokens, role: role, identifier: email);
  }
}
