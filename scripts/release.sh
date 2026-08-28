#!/usr/bin/env bash
#
# release.sh — MỘT phát: sinh CHANGELOG (từ prev-tag..master theo conventional commits)
#              → commit → annotated tag. KHÔNG push (in sẵn lệnh push).
#
# Dùng:  make release VERSION=v0.5.0          # làm thật
#        make release VERSION=v0.5.0 DRY=1    # chỉ xem trước mục CHANGELOG, không đụng gì
#
set -euo pipefail

VERSION="${1:-${VERSION:-}}"
DRY=0; [ "${2:-}" = "--dry" ] && DRY=1
[ -n "$VERSION" ] || { echo "Dùng: make release VERSION=v0.5.0 [DRY=1]" >&2; exit 1; }
case "$VERSION" in v*.*.*) ;; *) echo "LỖI: VERSION phải dạng vX.Y.Z" >&2; exit 1;; esac

prev="$(git describe --tags --abbrev=0 2>/dev/null || true)"
range="HEAD"; [ -n "$prev" ] && range="$prev..HEAD"

# --- sinh mục CHANGELOG từ conventional commits trong range ---
entry="$(python3 - "$VERSION" "$range" <<'PY'
import subprocess, sys, re, datetime
version, rng = sys.argv[1], sys.argv[2]
subs = subprocess.check_output(["git","log","--no-merges","--pretty=%s",rng], text=True).splitlines()
groups = {"Breaking":[], "Added / Changed":[], "Fixed":[], "Other":[]}
for s in subs:
    s=s.strip()
    if not s or s.startswith("chore(release)"): continue
    m=re.match(r'^(\w+)(\([^)]*\))?(!)?:\s*(.*)$', s)
    if not m: groups["Other"].append(f"- {s}"); continue
    typ, _scope, bang, desc = m.group(1), m.group(2), m.group(3), m.group(4)
    line=f"- {desc}"
    if bang: groups["Breaking"].append(line)
    elif typ=="feat": groups["Added / Changed"].append(line)
    elif typ=="fix": groups["Fixed"].append(line)
    elif typ in ("docs","chore","test","ci","style"):  # ít user-facing → gộp Other
        groups["Other"].append(line)
    else:  # refactor, perf, build...
        groups["Added / Changed"].append(line)
date=datetime.date.today().isoformat()
out=[f"## {version} — {date}",""]
for g in ["Breaking","Added / Changed","Fixed","Other"]:
    if groups[g]:
        out.append(f"### {g}"); out+=groups[g]; out.append("")
print("\n".join(out).rstrip())
PY
)"

if [ "$DRY" = 1 ]; then
  echo "===== CHANGELOG entry (DRY, chưa ghi/commit/tag) — range: ${range} ====="
  echo "$entry"
  echo "================================================================"
  echo "Chạy thật: make release VERSION=$VERSION"
  exit 0
fi

# --- guards cho làm thật ---
[ "$(git branch --show-current)" = "master" ] || { echo "LỖI: phải ở nhánh master" >&2; exit 1; }
[ -z "$(git status --porcelain)" ] || { echo "LỖI: cây làm việc chưa sạch — commit hết trước" >&2; exit 1; }
git rev-parse "$VERSION" >/dev/null 2>&1 && { echo "LỖI: tag $VERSION đã tồn tại" >&2; exit 1; }

# --- chèn entry vào CHANGELOG.md (sau ## [Unreleased], trên version trước) ---
python3 - "$entry" <<'PY'
import sys, re
entry=sys.argv[1].rstrip()+"\n\n"
s=open("CHANGELOG.md",encoding='utf-8').read()
m=re.search(r'## \[Unreleased\]\n+', s)
if m:
    s=s[:m.end()]+entry+s[m.end():]
else:
    # không có [Unreleased]: chèn trước mục version đầu tiên, hoặc cuối file
    m2=re.search(r'^## v\d', s, re.M)
    if m2: s=s[:m2.start()]+entry+s[m2.start():]
    else:  s=s.rstrip()+"\n\n"+entry
open("CHANGELOG.md","w",encoding='utf-8').write(s)
print("CHANGELOG.md updated")
PY

# --- bump tham chiếu version trong README.md về $VERSION (khỏi stale mỗi lần release) ---
# Nhắm: badge `release-vX.Y.Z` (version của chính repo) + ví dụ `b2b-gokit vX.Y.Z` / `scaffold@vX.Y.Z`
# (chỉ có ở core README; service README không khớp -> no-op an toàn).
[ -f README.md ] && python3 - "$VERSION" <<'PY'
import sys, re
v=sys.argv[1]
s=open("README.md",encoding='utf-8').read()
n=s
n=re.sub(r'release-v\d+\.\d+\.\d+', f'release-{v}', n)
n=re.sub(r'(ref: )v\d+\.\d+\.\d+', rf'\g<1>{v}', n)
n=re.sub(r'(flutter_kit )v\d+\.\d+\.\d+', rf'\g<1>{v}', n)
if n!=s:
    open("README.md","w",encoding='utf-8').write(n)
    print(f"README.md: bump version refs -> {v}")
PY

git add CHANGELOG.md README.md
git commit -q -m "chore(release): $VERSION"
# Annotated tag mang LUÔN release notes (= entry CHANGELOG) → đẩy lên GitLab thấy notes ở tag.
# --cleanup=verbatim: GIỮ nguyên markdown, không thì git strip mất dòng heading '##'/'###' (coi là comment).
printf '%s\n' "$entry" | git tag -a "$VERSION" -F - --cleanup=verbatim
echo "✓ $VERSION: CHANGELOG committed + annotated tag (kèm release notes) tạo xong (CHƯA push)."
echo "  Push:   git push origin master --tags        # tag + notes lên GitLab"
echo "  App pin: flutter_kit: {git: {url: ..., ref: $VERSION}}"
