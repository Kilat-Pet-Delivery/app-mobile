class ApiResponse<T> {
  final bool success;
  final T? data;
  final String? error;
  final String? detail;
  final PaginationMeta? pagination;

  const ApiResponse({
    required this.success,
    this.data,
    this.error,
    this.detail,
    this.pagination,
  });

  factory ApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(dynamic) fromJsonT,
  ) {
    return ApiResponse(
      success: json['success'] as bool? ?? false,
      data: json['data'] != null ? fromJsonT(json['data']) : null,
      error: json['error'] as String?,
      detail: json['detail'] as String?,
      pagination: json['pagination'] != null
          ? PaginationMeta.fromJson(
              json['pagination'] as Map<String, dynamic>)
          : null,
    );
  }
}

class PaginationMeta {
  final int total;
  final int page;
  final int limit;
  final int totalPages;

  const PaginationMeta({
    required this.total,
    required this.page,
    required this.limit,
    required this.totalPages,
  });

  factory PaginationMeta.fromJson(Map<String, dynamic> json) {
    return PaginationMeta(
      total: json['total'] as int? ?? 0,
      page: json['page'] as int? ?? 1,
      limit: json['limit'] as int? ?? 20,
      totalPages: json['total_pages'] as int? ?? 1,
    );
  }

  bool get hasNextPage => page < totalPages;
}

class PaginatedResult<T> {
  final List<T> items;
  final PaginationMeta pagination;

  const PaginatedResult({
    required this.items,
    required this.pagination,
  });
}
