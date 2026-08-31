---
name: git-flow
description: >-
  Áp dụng khi tạo nhánh Git, viết commit, chuẩn bị PR hoặc release trong app
  __name__. Ép đúng trunk-based trên `master`: nhánh <type>/<brief>, commit
  conventional "<type>(<scope>): <summary>", checklist pre-PR (codegen đã commit,
  no secret, analyze, test), SemVer tag. Nguồn chân lý: CONTRIBUTING.md.
---

# git-flow (__name__ — trunk-based trên `master`)

Nguồn chân lý đầy đủ: **`CONTRIBUTING.md`** ở gốc repo. Skill này là checklist để làm đúng ngay.

## Không bao giờ tự commit / push

**Tuyệt đối không `git commit`, `git push` hay `git tag` khi chưa được yêu cầu.** Đề xuất lệnh chính
xác (tên nhánh, full commit message, lệnh push/tag) rồi để user tự chạy. Sửa và stage file thì được.
Xem `git status` trước khi đụng index, và **không bao giờ `git add -A`** (add đúng file).

## Khi tạo nhánh

1. Base là `master`, đã pull mới: `git checkout master && git pull origin master`
2. Format: `<type>/<brief-3-words>` — `type` ∈ `feature|bugfix|hotfix|refactor|chore|docs|spike`.
   Có Jira/issue thì chèn key: `feature/B2B-123-profile-page`.

## Khi commit

- Format: `<type>(<scope>): <summary>` — `type` ∈ `feat|fix|refactor|test|docs|chore|perf|ci`;
  `scope` = tên feature hoặc vùng: `profile`, `auth`, `router`, `env`, `ci`, `deps`.
- Summary đọc-là-hiểu-đã-làm-gì. **Cấm** `update code`, `fix bug`, `done`, `wip`, `test`.
- **Commit kèm generated code** (`.g.dart`, `.freezed.dart`) — chúng nằm trong git, CI đỏ nếu stale.
- **Tuyệt đối không commit**: `.env`, `.env.*` (chỉ `.env.example`), `env.g.dart`, keystore/`.jks`,
  `key.properties`, `google-services.json`, `GoogleService-Info.plist`, token, debug log.

## Không bao giờ

- Push trực tiếp `master` — luôn qua branch + PR.
- Commit `dependency_overrides` hoặc `flutter_kit: {path: ...}` — kit phải pin `ref: vX.Y.Z`. Dev
  local dùng `pubspec_overrides.yaml` (đã gitignore).
- Bump `ref:` của flutter_kit trong cùng commit với thay đổi feature — tách riêng, kèm lý do và
  đã đọc CHANGELOG của kit.

## Khi chuẩn bị PR

CI **chỉ chạy khi có PR vào `master`** (hoặc bấm tay Actions → CI → *Run workflow*). Nghĩa là trên
nhánh, `make ci` ở local LÀ pipeline:

```bash
make ci   # get → gen → analyze → test
```

Thêm: generated code đã commit · no secret · đổi contract API → cập nhật doc/API collection ·
migration/state cần rollback note · chuyển Jira → *In Review*.

## Tag release

SemVer `vMAJOR.MINOR.PATCH` trên `master`, annotated tag kèm ghi chú:

```bash
git tag -a vX.Y.Z -m "vX.Y.Z — <tóm tắt>"
git push origin master --tags
```

Ghi rõ trong ghi chú release: app đang pin flutter_kit tag nào (đọc `pubspec.yaml`) — khi debug
sự cố production, đó là thông tin đầu tiên cần biết.
