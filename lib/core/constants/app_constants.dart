class AppConstants {
  AppConstants._();

  // Build-time env key: flutter run --dart-define=API_BASE_URL=https://api.example.com
  static const String apiBaseUrlKey = 'API_BASE_URL';
  static const String appEnvKey = 'APP_ENV';

  // Android emulator loopback to host machine.
  static const String defaultApiBaseUrl = 'http://10.10.10.245:8000';
  static const String defaultAppEnv = 'dev';

  static const int apiTimeoutSeconds = 15;
  static const int apiRetryCount = 2;
  static const bool enforceHttpsInProd = true;
  static const bool skipLoginForTesting = true;

  static const String accessTokenKey = 'auth_access_token';
  static const String refreshTokenKey = 'auth_refresh_token';
}

class ApiRoutes {
  ApiRoutes._();

  static const String sendNoticeEmail = '/api/send-notice-email';
  static const String login = '/api/login';
  static const String refreshToken = '/api/refresh';
  static const String register = '/api/register';
  static const String profile = '/api/profile';
  static const String logout = '/api/logout';
  static const String notices = '/api/notices';
}
