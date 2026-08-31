# Network

## The stack

`ref.watch(apiClientProvider)` returns a `Dio` configured from `KitConfig`, with interceptors in
this order:

1. **`AuthInterceptor`** — attaches `Authorization: Bearer <token>` from `TokenStore`; on `401`
   calls `tokenRefresherProvider` (if any) and replays the request once, otherwise fires
   `unauthorizedHandlerProvider` and raises `UnauthorizedException`.
2. **`RetryInterceptor`** — retries timeouts and `5xx`, `KitConfig.maxRetries` times with a linear
   backoff (`retryDelay * attempt`). `maxRetries: 0` removes it.
3. **`ErrorInterceptor`** — maps every `DioException` to a sealed `ApiException`. Nothing above this
   line ever sees a Dio type.
4. **`PrettyDioLogger`** — when `KitConfig.enableNetworkLogging` (debug by default; keep it off in
   production, request bodies leak).
5. **`extraInterceptorsProvider`** — your additions, last.

Never construct `Dio()` yourself: you'd lose auth, retry and the error contract in one line.

## Datasource → repository → provider

The wire format is [the gokit contract](api-contract.md) — `{"data": ...}` on success, RFC 9457
problem details on failure. Unwrap with `ApiData` / `ApiPage`, never by hand:

```dart
// data/datasources/ — URLs and JSON only
Future<UserModel> getProfile() async {
  final response = await dio.get<Map<String, dynamic>>('/auth/profile');
  return ApiData<UserModel>.fromJson(
    response.data!,
    (json) => UserModel.fromJson(json! as Map<String, dynamic>),
  ).data;
}

// data/repositories/ — errors become Result, DTOs become entities
Future<Result<User>> getProfile() =>
    apiCall(() async => (await remote.getProfile()).toEntity());
```

`apiCall` catches `DioException`/`ApiException`/`Exception` and returns `Result<T>` —
`Success<T>` or `Failure` carrying an `ApiException`.

Endpoints that must not carry a token (login, refresh):
`Options(extra: {'skip_auth': true})`.

## Errors

`ApiException` is **sealed**, so a `switch` over it is exhaustive and a new subtype breaks the
compile instead of silently falling into a default branch. Subtypes follow gokit's stable `code`,
not the HTTP status — the full mapping table is in [api-contract.md](api-contract.md#errors--rfc-9457-problem-details).

`NotFoundException` · `UnauthorizedException` · `ForbiddenException` · `ValidationException` ·
`ConflictException` · `RateLimitedException` · `TimeoutException` · `NetworkException` ·
`ServerException` · `UnknownApiException`

Each carries `code`, `statusCode`, `title`, `message` (the server's `detail`) and `traceId`.

- **User-facing copy**: `ref.read(apiErrorMessagesProvider).message(e)` — override the provider to
  localize. Never show `detail` or `traceId` to a user; never write error strings in a widget.
- **Forms**: `ValidationException.reasonFor('email')` binds the server's field errors to inputs.
- **Support/debugging**: log `traceId` — `ErrorInterceptor` already does, and it is what backend
  searches on.

## Pagination

gokit paginates by opaque cursor. Mix `PaginatedNotifier<T>` into a notifier, implement
`fetchPage(String? cursor)` returning `ApiPage<T>`, then render with `PaginatedListView<T>`:

```dart
@riverpod
class ArticleList extends _$ArticleList with PaginatedNotifier<Article> {
  @override
  Future<ApiPage<Article>> fetchPage(String? cursor) async {
    final result = await ref
        .read(articleRepositoryProvider)
        .fetchPage(cursor: cursor, limit: pageSize);
    return switch (result) {
      Success(:final data) => data,
      Failure(:final exception) => throw exception, // lands in state.error
    };
  }

  @override
  PaginatedState<Article> build() {
    loadFirstPage();
    return const PaginatedState();
  }
}
```

The mixin owns the in-flight guard, the cursor and error capture; the widget owns the scroll
threshold, load-more spinner, pull-to-refresh and empty state. Trust `hasMore` from the server — a
short page is not the end of the list.
