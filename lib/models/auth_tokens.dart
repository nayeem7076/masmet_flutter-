class AuthTokens {
  final String accessToken;
  final String refreshToken;

  const AuthTokens({required this.accessToken, required this.refreshToken});

  factory AuthTokens.fromJson(Map<String, dynamic> json) {
    return AuthTokens(
      accessToken:
          (json['accessToken'] ?? json['access_token'] ?? '').toString(),
      refreshToken:
          (json['refreshToken'] ?? json['refresh_token'] ?? '').toString(),
    );
  }

  bool get isValid => accessToken.isNotEmpty && refreshToken.isNotEmpty;
}
