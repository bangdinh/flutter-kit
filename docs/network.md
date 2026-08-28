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

```dart
// data/datasources/ — URLs and JSON only
Future<UserModel> getProfile() async {
  final response = await dio.get<Map<String, dynamic>>('/auth/profile');
  return UserModel.fromJson(response.data!['data']! as Map<String, dynamic>);
}

// data/repositories/ — errors become Result, tokens get persisted
Future<Result<User>> getProfile() =>
    apiCall(() async => (await remote.getProfile()).toEntity());
```

`apiCall` catches `DioException`/`ApiException`/`Exception` and returns `Result<T>` —
`Success<T>` or `Failure` carrying an `ApiException`.

Endpoints that must not carry a token (login, refresh):
`Options(extra: {'skip_auth': true})`.

## Errors

`ApiException` is **sealed**, so a `switch` over it is exhaustive and a new subtype breaks the
compile instead of silently falling into a default branch:

| Subtype | Raised on |
|---|---|
| `UnauthorizedException` | `401`, after refresh failed or was absent |
| `NotFoundException` | `404` |
| `ServerException` | other `4xx`/`5xx` (carries `statusCode`, parsed `message`) |
| `TimeoutException` | connect/send/receive timeout |
| `NetworkException` | connection error, `SocketException` |
| `UnknownApiException` | cancelled, or anything unmapped |

User-facing copy: `ref.read(apiErrorMessagesProvider).message(e)` — override the provider to
localize. Don't write error strings in widgets.

## Pagination

Mix `PaginatedNotifier<T>` into a notifier, implement `fetchPage(page)` returning
`PaginatedResponse<T>`, then render with `PaginatedListView<T>`:

```dart
@riverpod
class ArticleList extends _$ArticleList with PaginatedNotifier<Article> {
  @override
  Future<PaginatedResponse<Article>> fetchPage(int page) =>
      ref.read(articleRepositoryProvider).getArticles(page: page, limit: pageSize);

  @override
  PaginatedState<Article> build() {
    loadFirstPage();
    return const PaginatedState();
  }
}
```

The widget handles the scroll threshold, load-more spinner, pull-to-refresh and empty state.
