class AppConstants {
  AppConstants._();

  // Build-time env key: flutter run --dart-define=API_BASE_URL=https://api.example.com
  static const String apiBaseUrlKey = 'API_BASE_URL';
  static const String appEnvKey = 'APP_ENV';

  // Android emulator loopback to host machine.
  static const String defaultApiBaseUrl = 'http://10.0.2.2:5000';
  static const String defaultAppEnv = 'dev';

  static const int apiTimeoutSeconds = 15;
  static const int apiRetryCount = 2;
  static const bool enforceHttpsInProd = true;

  static const String accessTokenKey = 'auth_access_token';
  static const String refreshTokenKey = 'auth_refresh_token';
}

class ApiRoutes {
  ApiRoutes._();

  static const String sendNoticeEmail = '/api/send-notice-email';
  static const String login = '/api/auth/login';
  static const String refreshToken = '/api/auth/refresh';
  static const String register = '/api/auth/register';
}
