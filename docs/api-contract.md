# API contract (b2b-gokit)

Every service the kit talks to is built on **b2b-gokit** and follows VMSN-STD-API-001. The kit
implements that contract once so no app re-derives it — and so a server-side change is a kit bump,
not a search through every datasource.

## Success — `data`, and nothing else

```json
{"data": {"id": "res_123", "displayName": "Example"}}

{"data": [{"id": "res_123"}],
 "page": {"limit": 50, "nextCursor": "eyJpZCI6...", "hasMore": true}}
```

There is **no** `success`, `message`, `status` or `codeStatus` field. The HTTP status carries the
outcome. `204` has no body at all; `201` sets `Location`; an empty collection is `200` with
`"data": []`, never `404`.

Unwrap with the kit's helpers — never index `response.data['data']` by hand:

```dart
final user = ApiData<UserModel>.fromJson(
  response.data!,
  (json) => UserModel.fromJson(json! as Map<String, dynamic>),
).data;

final page = ApiPage<OrderModel>.fromJson(
  response.data!,
  (json) => OrderModel.fromJson(json! as Map<String, dynamic>),
);
```

A body without `data` throws `FormatException`. That is deliberate: a broken contract should fail at
the datasource, not surface as a null three screens away.

## Pagination is by cursor

`page` carries `limit`, `nextCursor`, `hasMore` and an **optional** `total` — services compute
`total` only when it is cheap, so never build UI that requires it.

- `nextCursor` is **opaque**. Echo it back untouched; don't parse, increment or persist it.
- `hasMore` is authoritative. A short page does not mean the end.
- There is no page number and no "jump to page 7".

`PaginatedNotifier<T>` + `PaginatedState<T>` + `PaginatedListView<T>` implement exactly this — see
[network.md](network.md#pagination).

## Errors — RFC 9457 problem details

`Content-Type: application/problem+json`. Never a 200 with an error inside; success and error shapes
never mix.

```json
{"type": "about:blank", "title": "Validation failed", "status": 422,
 "code": "VALIDATION_FAILED", "traceId": "abc123",
 "errors": [{"field": "email", "code": "REQUIRED", "reason": "is required"}]}
```

**Switch on `code`, not on `status`.** The code is the stable contract; several codes share a status
(`CONFLICT` and `ALREADY_EXISTS` are both 409) and a status alone can't tell them apart.

| gokit `code` | Kit exception | Status |
|---|---|---|
| `NOT_FOUND` | `NotFoundException` | 404 |
| `UNAUTHORIZED` | `UnauthorizedException` | 401 |
| `FORBIDDEN` | `ForbiddenException` | 403 |
| `INVALID_INPUT`, `VALIDATION_FAILED`, `OUT_OF_RANGE` | `ValidationException` (has `fieldErrors`) | 400 / 422 |
| `ALREADY_EXISTS`, `CONFLICT`, `PRECONDITION_FAILED` | `ConflictException` | 409 / 412 |
| `RATE_LIMITED` | `RateLimitedException` (has `retryAfter`) | 429 |
| `TIMEOUT` | `TimeoutException` | 504 |
| `INTERNAL_ERROR`, `SERVICE_UNAVAILABLE`, `DATA_LOSS`, `UNIMPLEMENTED` | `ServerException` | 5xx |
| *(no response at all)* | `NetworkException` | — |
| unrecognised | falls back to the status, else `UnknownApiException` | — |

`ApiErrorCode` keeps the original code even where several map to one exception
(`ConflictException(code: ApiErrorCode.alreadyExists)`), so a screen that needs the distinction has
it. An unknown code degrades to a status-based match rather than throwing — a service adding a code
must never break a shipped app.

## traceId — log it, don't show it

Every problem body carries `traceId` (the kit also reads `X-Request-Id` when the body omits it). It
is what backend searches on. `ErrorInterceptor` logs it automatically; put it in bug reports and
crash breadcrumbs.

Never render it to a user, and never render the server's `detail` either — user-facing wording comes
from `apiErrorMessagesProvider`, which an app can localize.

## Field errors bind to forms

```dart
if (result case Failure(exception: final ValidationException e)) {
  setState(() => _emailError = e.reasonFor('email'));
}
```

`ValidationException.fieldErrors` is the server's `errors[]`, with the field path as the API names
it. Prefer it over parsing `detail`.

## When the server breaks the contract

Not every hop is a gokit service — a gateway, a proxy or an nginx error page can answer instead.
`ErrorInterceptor` treats a JSON body as a problem only when it carries a `code`, a `title` or a
`detail`; anything else is classified by HTTP status. Nothing throws inside the interceptor.
