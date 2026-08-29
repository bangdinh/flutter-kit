# Makefile — dev tooling for flutter_kit (library) + example app.
# `make` or `make help` lists the commands.
#
# The kit and example/ are SEPARATE packages: most targets run in both, which is
# why each has a `-kit` / `-example` variant.

.DEFAULT_GOAL := help
.PHONY: help get gen gen-watch clean analyze format test test-coverage \
        get-example gen-example analyze-example test-example \
        run-dev run-stg run-prod ci release new-app sync-skill verify-skill

DART ?= dart
FLUTTER ?= flutter
EXAMPLE = example

help: ## List commands (default)
	@echo "flutter_kit — commands:"
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "  \033[36m%-16s\033[0m %s\n", $$1, $$2}' $(MAKEFILE_LIST)

## ── Dependencies ────────────────────────────────────────────────────────────
get: ## pub get for the kit (also resolves example/)
	$(FLUTTER) pub get

get-example: ## pub get for the example app only
	cd $(EXAMPLE) && $(FLUTTER) pub get

## ── Code generation (riverpod / freezed / json / envied) ────────────────────
gen: ## build_runner for the kit (build.yaml keeps example/ out)
	$(DART) run build_runner build

gen-example: ## build_runner for the example app
	cd $(EXAMPLE) && $(DART) run build_runner build

gen-watch: ## build_runner watch for the kit
	$(DART) run build_runner watch

## ── Quality ─────────────────────────────────────────────────────────────────
# `flutter analyze` crashes on some machines (Homebrew dart conflict) — the kit
# always uses `dart analyze`, which is what CI runs too.
analyze: ## dart analyze the kit
	$(DART) analyze lib bin test

analyze-example: ## dart analyze the example app
	cd $(EXAMPLE) && $(DART) analyze lib test

format: ## dart format kit + example
	$(DART) format lib bin test $(EXAMPLE)/lib $(EXAMPLE)/test --line-length 80

## ── Tests ───────────────────────────────────────────────────────────────────
test: ## flutter test for the kit
	$(FLUTTER) test

test-example: ## flutter test for the example app
	cd $(EXAMPLE) && $(FLUTTER) test

test-coverage: ## kit tests with coverage (coverage/lcov.info)
	$(FLUTTER) test --coverage

## ── Run the example app ─────────────────────────────────────────────────────
run-dev: ## run example against dev
	cd $(EXAMPLE) && $(FLUTTER) run --dart-define=ENV=dev

run-stg: ## run example against staging
	cd $(EXAMPLE) && $(FLUTTER) run --dart-define=ENV=staging

run-prod: ## run example against prod (release)
	cd $(EXAMPLE) && $(FLUTTER) run --dart-define=ENV=prod --release

## ── Everything CI runs, locally ─────────────────────────────────────────────
clean: ## flutter clean both packages, then pub get
	$(FLUTTER) clean
	cd $(EXAMPLE) && $(FLUTTER) clean
	rm -rf .dart_tool build $(EXAMPLE)/.dart_tool $(EXAMPLE)/build
	$(FLUTTER) pub get

ci: get gen verify-skill analyze test get-example gen-example analyze-example test-example ## full local CI
	@echo "✅ kit + example: analyze and tests passed"

## ── Scaffold a new app ──────────────────────────────────────────────────────
# make new-app NAME=camera_b2b ORG=vn.fpt              → ../camera_b2b, kit pinned to latest tag
# make new-app NAME=camera_b2b OUT=~/work/camera_b2b   → elsewhere
# make new-app NAME=camera_b2b EXTRA="--local"         → DEV: path dependency on this working tree
# make new-app NAME=camera_b2b EXTRA="--kit-ref v0.2.0"
new-app: ## scaffold a new app (NAME=, ORG=, OUT=, EXTRA=)
	@test -n "$(NAME)" || { echo "Usage: make new-app NAME=<app_name> [ORG=vn.fpt] [OUT=dir] [EXTRA=flags]"; exit 1; }
	$(DART) run bin/scaffold.dart --name $(NAME) \
	  $(if $(ORG),--org $(ORG),) $(if $(OUT),--out $(OUT),) $(EXTRA)

## ── Shared files: kit is the source of truth, templates mirror it ───────────
# flutter-arch (architecture) and flutter-testing (how to test) are standards:
# they must read identically in the kit and in every generated app, so they are
# copied, not rewritten. Run sync-skill after editing the original; verify-skill
# (also in CI) fails if they drift. feature-flow and the app's git-flow are
# app-only and live in templates/ alone. kit-scaffold and kit-extension-point
# are kit-only — a generated app has no templates/ and no public API to widen.
SHARED_FILES = .claude/skills/flutter-arch/SKILL.md \
               .claude/skills/flutter-testing/SKILL.md

sync-skill: ## copy shared skill files kit -> templates/app (run after editing them)
	@for f in $(SHARED_FILES); do \
		mkdir -p "templates/app/$$(dirname $$f)"; \
		cp "$$f" "templates/app/$$f"; \
		echo "synced -> templates/app/$$f"; \
	done

verify-skill: ## fail if a shared skill file drifted from its template copy
	@ok=1; for f in $(SHARED_FILES); do \
		diff -q "$$f" "templates/app/$$f" >/dev/null 2>&1 || { echo "DRIFT: $$f"; ok=0; }; \
	done; [ $$ok = 1 ] && echo "✓ shared skill files match templates" || { echo "→ run 'make sync-skill'"; exit 1; }

## ── Release (maintainer) ────────────────────────────────────────────────────
# make release VERSION=v0.2.0        → CHANGELOG + commit + annotated tag (no push)
# make release VERSION=v0.2.0 DRY=1  → preview the CHANGELOG entry only
release: ## CHANGELOG + tag for VERSION (DRY=1 to preview)
	@test -n "$(VERSION)" || { echo "Usage: make release VERSION=vX.Y.Z [DRY=1]"; exit 1; }
	@bash scripts/release.sh "$(VERSION)" $(if $(DRY),--dry,)
