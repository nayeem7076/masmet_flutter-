import '../core/constants/app_constants.dart';
import 'secure_storage_service.dart';

class AuthTokenService {
  static Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    await SecureStorageService.write(AppConstants.accessTokenKey, accessToken);
    await SecureStorageService.write(
        AppConstants.refreshTokenKey, refreshToken);
  }

  static Future<String?> getAccessToken() async {
    return SecureStorageService.read(AppConstants.accessTokenKey);
  }

  static Future<String?> getRefreshToken() async {
    return SecureStorageService.read(AppConstants.refreshTokenKey);
  }

  static Future<void> clearTokens() async {
    await SecureStorageService.delete(AppConstants.accessTokenKey);
    await SecureStorageService.delete(AppConstants.refreshTokenKey);
  }
}
