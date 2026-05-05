class AuthTokens {
  final String accessToken;
  final String refreshToken;

  const AuthTokens({required this.accessToken, required this.refreshToken});

  factory AuthTokens.fromJson(Map<String, dynamic> json) {
    final token =
        (json['token'] ?? json['accessToken'] ?? json['access_token'] ?? '')
            .toString();
    final refresh =
        (json['refreshToken'] ?? json['refresh_token'] ?? token).toString();
    return AuthTokens(
      accessToken: token,
      refreshToken: refresh,
    );
  }

  bool get isValid => accessToken.isNotEmpty;
}
