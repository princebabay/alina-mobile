class ApiSuccessResponse<T> {
  final bool success;
  final String message;
  final T data;

  ApiSuccessResponse({
    required this.success,
    required this.message,
    required this.data,
  });
}

class ApiErrorResponse {
  final bool success;
  final String message;
  final dynamic errors;

  ApiErrorResponse({required this.success, required this.message, this.errors});
}

class ApiResponse<T> {
  final bool success;
  final String message;
  final T? data;
  final dynamic errors;

  ApiResponse({
    required this.success,
    required this.message,
    this.data,
    this.errors,
  });

  factory ApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(dynamic data) fromData,
  ) {
    return ApiResponse<T>(
      success: json['success'],
      message: json['message'],
      data: json['success'] == true && json['data'] != null
          ? fromData(json['data'])
          : null,
      errors: json['errors'],
    );
  }
}
