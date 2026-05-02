import '../constants/app_constants.dart';

class ApiConfig {
  // Set with: --dart-define=API_BASE_URL=https://your-domain.com
  static const String baseUrl = String.fromEnvironment(
    AppConstants.apiBaseUrlKey,
    defaultValue: AppConstants.defaultApiBaseUrl,
  );

  static const Duration connectTimeout = Duration(
    seconds: AppConstants.apiTimeoutSeconds,
  );

  static const String appEnv = String.fromEnvironment(
    AppConstants.appEnvKey,
    defaultValue: AppConstants.defaultAppEnv,
  );

  static bool get isProduction => appEnv.toLowerCase() == 'prod';

  static void validate() {
    if (AppConstants.enforceHttpsInProd &&
        isProduction &&
        !baseUrl.toLowerCase().startsWith('https://')) {
      throw StateError(
        'In production, API_BASE_URL must use HTTPS. Current: $baseUrl',
      );
    }
  }
}
