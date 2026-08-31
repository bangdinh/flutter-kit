import 'package:flutter/foundation.dart';

/// Stable error codes emitted by b2b-gokit services (`errors.Code`).
///
/// The **code** — not the HTTP status — is what client logic switches on: it is
/// stable across refactors, and several codes share one status (`CONFLICT` and
/// `ALREADY_EXISTS` are both 409).
enum ApiErrorCode {
  notFound('NOT_FOUND'),
  unauthorized('UNAUTHORIZED'),
  forbidden('FORBIDDEN'),
  invalidInput('INVALID_INPUT'),
  validationFailed('VALIDATION_FAILED'),
  alreadyExists('ALREADY_EXISTS'),
  internalError('INTERNAL_ERROR'),
  serviceUnavailable('SERVICE_UNAVAILABLE'),
  timeout('TIMEOUT'),
  rateLimited('RATE_LIMITED'),
  conflict('CONFLICT'),
  preconditionFailed('PRECONDITION_FAILED'),
  outOfRange('OUT_OF_RANGE'),
  unimplemented('UNIMPLEMENTED'),
  dataLoss('DATA_LOSS'),

  /// Not a gokit code. Either the transport failed before there was a body, or
  /// the service sent a code this version of the kit predates — a new server
  /// code must degrade, never crash the app.
  unknown('UNKNOWN');

  const ApiErrorCode(this.wireValue);

  /// The `code` field as it appears on the wire.
  final String wireValue;

  static ApiErrorCode fromWire(String? value) {
    if (value == null) return ApiErrorCode.unknown;
    for (final code in ApiErrorCode.values) {
      if (code.wireValue == value) return code;
    }
    return ApiErrorCode.unknown;
  }
}

/// One field-level validation failure (`errors[]` in the problem body).
@immutable
class FieldError {
  const FieldError({required this.field, required this.reason, this.code});

  /// Field path as the API names it, e.g. `email` or `items[0].qty`.
  final String field;

  /// Human-readable reason.
  final String reason;

  /// Stable per-field code in UPPER_SNAKE, e.g. `REQUIRED`. Optional.
  final String? code;

  factory FieldError.fromJson(Map<String, dynamic> json) {
    return FieldError(
      field: json['field'] as String? ?? '',
      reason: json['reason'] as String? ?? '',
      code: json['code'] as String?,
    );
  }

  @override
  String toString() => '$field: $reason${code != null ? ' ($code)' : ''}';
}

/// RFC 9457 Problem Details — the error body every gokit service returns, with
/// `Content-Type: application/problem+json`.
///
/// ```json
/// {"type": "about:blank", "title": "Validation failed", "status": 422,
///  "code": "VALIDATION_FAILED", "traceId": "abc123",
///  "errors": [{"field": "email", "code": "REQUIRED", "reason": "is required"}]}
/// ```
///
/// Success and error shapes never mix: an error body has no `data`, a success
/// body has no `code`/`title`.
@immutable
class ProblemDetail {
  const ProblemDetail({
    required this.status,
    required this.code,
    this.type = 'about:blank',
    this.title = '',
    this.detail,
    this.traceId,
    this.fieldErrors = const [],
  });

  /// URI reference for the error type; gokit sends `about:blank`.
  final String type;

  /// Short summary, stable across instances ("Resource not found").
  final String title;

  final int status;

  /// Stable code — switch on this, not on [status].
  final ApiErrorCode code;

  /// Explanation that may vary per instance.
  final String? detail;

  /// Correlation id for tracing this request server-side. Log it; quote it in
  /// bug reports — it is how backend finds the request.
  final String? traceId;

  /// Field-level failures, present on `VALIDATION_FAILED`.
  final List<FieldError> fieldErrors;

  /// Parses a problem body defensively: a malformed or partial body still
  /// yields a usable ProblemDetail rather than throwing inside an interceptor.
  factory ProblemDetail.fromJson(
    Map<String, dynamic> json, {
    int? fallbackStatus,
  }) {
    final rawErrors = json['errors'];
    return ProblemDetail(
      type: json['type'] as String? ?? 'about:blank',
      title: json['title'] as String? ?? '',
      status: json['status'] as int? ?? fallbackStatus ?? 0,
      code: ApiErrorCode.fromWire(json['code'] as String?),
      detail: json['detail'] as String?,
      traceId: json['traceId'] as String?,
      fieldErrors:
          rawErrors is List
              ? rawErrors
                  .whereType<Map<String, dynamic>>()
                  .map(FieldError.fromJson)
                  .toList(growable: false)
              : const [],
    );
  }

  /// Best available human-readable text — never for end users (use
  /// `apiErrorMessagesProvider` for that), but right for logs.
  String get message => detail?.isNotEmpty == true ? detail! : title;

  @override
  String toString() =>
      'ProblemDetail(${code.wireValue}, $status, "$message"'
      '${traceId != null ? ', trace=$traceId' : ''})';
}
