/// Generic wrapper for API responses.
///
/// Adapts to common REST patterns:
///   { "data": ..., "message": "...", "status": 200 }
class ApiResponse<T> {
  const ApiResponse({
    this.data,
    this.message,
    this.statusCode,
    this.success = true,
  });

  final T? data;
  final String? message;
  final int? statusCode;
  final bool success;

  factory ApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Object? json)? fromJsonT,
  ) {
    return ApiResponse<T>(
      data:
          json['data'] != null && fromJsonT != null
              ? fromJsonT(json['data'])
              : json['data'] as T?,
      message: json['message'] as String?,
      statusCode: json['status'] as int? ?? json['statusCode'] as int?,
      success: json['success'] as bool? ?? true,
    );
  }
}

/// Paginated response wrapper.
class PaginatedResponse<T> {
  const PaginatedResponse({
    required this.items,
    required this.page,
    required this.totalPages,
    this.totalItems,
  });

  final List<T> items;
  final int page;
  final int totalPages;
  final int? totalItems;

  bool get hasMore => page < totalPages;
}
