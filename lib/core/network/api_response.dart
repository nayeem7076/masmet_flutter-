class ApiResponse<T> {
  final bool success;
  final String message;
  final T? data;

  const ApiResponse({
    required this.success,
    required this.message,
    this.data,
  });

  factory ApiResponse.fromJson(
    Map<String, dynamic> json, {
    T Function(Object?)? dataParser,
  }) {
    return ApiResponse<T>(
      success: (json['success'] as bool?) ?? true,
      message: (json['message'] as String?) ?? '',
      data: dataParser == null ? json['data'] as T? : dataParser(json['data']),
    );
  }
}
