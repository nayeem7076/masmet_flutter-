class AppConstants {
  AppConstants._();

  // Build-time env key: flutter run --dart-define=API_BASE_URL=https://api.example.com
  static const String apiBaseUrlKey = 'API_BASE_URL';
  static const String appEnvKey = 'APP_ENV';

  // Android emulator loopback to host machine.
  static const String defaultApiBaseUrl = 'http://192.168.0.156:8001';
  static const String defaultAppEnv = 'dev';

  static const int apiTimeoutSeconds = 15;
  static const int apiRetryCount = 2;
  static const bool enforceHttpsInProd = true;
  // Enable only when explicitly needed:
  // flutter run --dart-define=SKIP_LOGIN_FOR_TESTING=true
  static const bool skipLoginForTesting = bool.fromEnvironment(
    'SKIP_LOGIN_FOR_TESTING',
    defaultValue: true,
  );

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
