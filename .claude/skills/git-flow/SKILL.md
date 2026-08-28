---
name: git-flow
description: >-
  Áp dụng khi tạo nhánh Git, viết commit, chuẩn bị PR hoặc release/tag trong repo
  flutter-kit (và app sinh ra từ nó). Ép đúng trunk-based trên `master`:
  nhánh <type>/<brief>, commit conventional "<type>(<scope>): <summary>",
  checklist pre-PR (no secret, codegen, analyze, test), SemVer tag + CHANGELOG.
  Nguồn chân lý: CONTRIBUTING.md.
---

# git-flow (flutter-kit — trunk-based trên `master`)

Nguồn chân lý đầy đủ: **`CONTRIBUTING.md`** ở gốc repo. Skill này là checklist để làm đúng ngay.

## Không bao giờ tự commit / push

**Tuyệt đối không `git commit`, `git push` hay `git tag` khi chưa được yêu cầu.** Đề xuất lệnh
chính xác (tên nhánh, full commit message, lệnh push/tag) rồi để user tự chạy — kể cả khi task
"rõ ràng cần commit". Sửa và stage file thì được. User thường làm song song, nên: xem
`git status` trước khi đụng index, và **không bao giờ `git add -A`** (add đúng file).

## Khi tạo nhánh

1. Base luôn là `master`, đã pull mới: `git checkout master && git pull origin master`
2. Format: `<type>/<brief-3-words>` — `type` ∈ `feature|bugfix|refactor|chore|docs|spike`.
   Có Jira/issue thì chèn key vào giữa: `feature/B2B-123-token-refresh`.
3. `git checkout -b <type>/<brief>`

## Khi commit

- Format: `<type>(<scope>): <summary>` — `type` ∈ `feat|fix|refactor|test|docs|chore|perf|ci`.
  `scope` = vùng ảnh hưởng: `network`, `theme`, `app`, `storage`, `ui`, `example`, `docs`, `skills`.
  Breaking API của kit → thêm `!`: `feat(network)!: ...` (release.sh xếp vào mục **Breaking**).
- Summary đọc-là-hiểu-đã-làm-gì. **Cấm** `update code`, `fix bug`, `done`, `wip`, `test`, `abc`.
- Commit nhỏ, một mục đích. Không trộn codegen output với thay đổi logic khi tránh được.
- Trước khi commit: KHÔNG đưa `.env.*`, keystore, token, key, debug log vào. Chỉ commit `*.example`.
  `example/.env.*` đã nằm trong `.gitignore` — giữ nguyên như vậy.

## Không bao giờ

- Push trực tiếp lên `master` — luôn qua branch + Pull Request.
- Re-tag một version đã push (làm hỏng cache `pub` của mọi app đang pin tag đó). Cần sửa → ra
  version mới.
- Commit `dependency_overrides` hay `flutter_kit: {path: ...}` trong `pubspec.yaml` của một app;
  chỉ dùng local qua `pubspec_overrides.yaml` (không commit). `example/` là ngoại lệ hợp lệ duy nhất.

## Khi chuẩn bị PR

CI **chỉ chạy khi có PR vào `master`** (hoặc user tự bấm Actions → CI → *Run workflow*), cố ý vậy
để commit hằng ngày trên feature branch không spam pipeline. Nghĩa là trên nhánh, `make ci` ở local
LÀ pipeline — chạy nó trước khi mở PR, đừng đẩy lên rồi chờ CI báo.

Checklist trước khi mở PR — chạy cả **gốc** và **example/** (hai package riêng):

```bash
dart run build_runner build && dart analyze lib test && flutter test
(cd example && dart run build_runner build && dart analyze lib test && flutter test)
```

Thêm: no secret/debug log · **generated code (`.g.dart`, `.freezed.dart`) đã chạy `make gen` /
`make gen-example` và commit kèm** (trừ `env.g.dart` — không bao giờ commit) · đổi public API của
kit → cập nhật `docs/` + mục `## [Unreleased]` trong `CHANGELOG.md` · quyết định khó đảo → thêm ADR
ở `docs/adr/`.

## Tag release (chỉ trên `master`)

SemVer `vMAJOR.MINOR.PATCH`. Pre-1.0: **MINOR** = feature *hoặc* breaking, **PATCH** = fix tương
thích ngược. Sau 1.0: MAJOR = breaking. App pin tag chính xác, nên tag là hợp đồng — đừng bump
bừa.

**Một phát:** `make release VERSION=vX.Y.Z` — sinh CHANGELOG từ conventional commits
(`prev-tag..master`) → commit → annotated tag kèm release notes (guard: đúng nhánh `master` +
cây sạch). Xem trước: thêm `DRY=1`.

Rồi **user tự chạy**: `git push origin master --tags`

**Soạn tay CHANGELOG khi cần:**
1. Tag gần nhất: `git describe --tags --abbrev=0`
2. Thay đổi từ đó: `git log --oneline <prev-tag>..master`
3. Mục `## vX.Y.Z — <ngày>` đặt TRÊN version trước, giữ `## [Unreleased]` rỗng ở đầu file. Nhóm
   **Breaking / Added / Changed / Fixed**. Diễn giải user-facing, gộp commit liên quan — không
   dán raw commit.
4. Commit `CHANGELOG.md` TRƯỚC, rồi mới tag.
