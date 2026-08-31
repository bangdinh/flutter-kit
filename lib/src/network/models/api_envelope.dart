import 'package:flutter/foundation.dart';

/// The success envelope every b2b-gokit service returns (VMSN-STD-API-001 §06).
///
/// Single resource: `{"data": {...}}` · collection:
/// `{"data": [...], "page": {"limit": 50, "nextCursor": "…", "hasMore": true}}`.
/// There is no `success`, `message`, `status` or `codeStatus` field — the HTTP
/// status carries the outcome, and errors use `application/problem+json`.
///
/// Datasources unwrap with these helpers rather than reaching into
/// `response.data['data']` by hand, so a contract change lands in one place.
@immutable
class ApiData<T> {
  const ApiData(this.data);

  final T data;

  /// Unwraps `{"data": ...}`.
  ///
  /// Throws [FormatException] when `data` is missing — that is a broken
  /// contract, and failing loudly beats a null that surfaces three screens away.
  factory ApiData.fromJson(
    Map<String, dynamic> json,
    T Function(Object? json) fromJsonT,
  ) {
    if (!json.containsKey('data')) {
      throw const FormatException(
        'Response has no "data" field — not a gokit success envelope.',
      );
    }
    return ApiData(fromJsonT(json['data']));
  }
}

/// Cursor pagination metadata (`page` in the envelope).
///
/// gokit paginates by **cursor**, not page number: [nextCursor] is opaque and
/// must be echoed back untouched. `total` is optional — services only compute it
/// when it is cheap, so never build UI that requires it.
@immutable
class PageMeta {
  const PageMeta({
    this.limit,
    this.nextCursor,
    this.hasMore = false,
    this.total,
  });

  /// Items per page the server applied (it may clamp what was asked for).
  final int? limit;

  /// Opaque cursor for the next page; `null`/empty when there is none.
  final String? nextCursor;

  final bool hasMore;

  /// Total matching items, only when the service could compute it cheaply.
  final int? total;

  factory PageMeta.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const PageMeta();
    final cursor = json['nextCursor'] as String?;
    return PageMeta(
      limit: json['limit'] as int?,
      nextCursor: (cursor?.isEmpty ?? true) ? null : cursor,
      hasMore: json['hasMore'] as bool? ?? false,
      total: (json['total'] as num?)?.toInt(),
    );
  }

  @override
  String toString() =>
      'PageMeta(limit: $limit, hasMore: $hasMore, '
      'nextCursor: ${nextCursor != null ? '…' : 'null'}, total: $total)';
}

/// The collection envelope: `{"data": [...], "page": {...}}`.
@immutable
class ApiPage<T> {
  const ApiPage({required this.items, this.page = const PageMeta()});

  final List<T> items;
  final PageMeta page;

  /// Prefer [PageMeta.hasMore] over "did I get a full page?" — a service may
  /// return fewer items than the limit and still have more.
  bool get hasMore => page.hasMore;

  String? get nextCursor => page.nextCursor;

  /// Unwraps `{"data": [...], "page": {...}}`. An empty collection is
  /// `{"data": []}` with status 200 — never a 404.
  factory ApiPage.fromJson(
    Map<String, dynamic> json,
    T Function(Object? json) fromJsonT,
  ) {
    final data = json['data'];
    if (data is! List) {
      throw const FormatException(
        'Response "data" is not a list — not a gokit page envelope.',
      );
    }
    return ApiPage(
      items: data.map(fromJsonT).toList(growable: false),
      page: PageMeta.fromJson(json['page'] as Map<String, dynamic>?),
    );
  }
}
