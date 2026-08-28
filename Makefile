# Makefile — dev tooling for flutter_kit (library) + example app.
# `make` or `make help` lists the commands.
#
# The kit and example/ are SEPARATE packages: most targets run in both, which is
# why each has a `-kit` / `-example` variant.

.DEFAULT_GOAL := help
.PHONY: help get gen gen-watch clean analyze format test test-coverage \
        get-example gen-example analyze-example test-example \
        run-dev run-stg run-prod ci release

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
	$(DART) analyze lib test

analyze-example: ## dart analyze the example app
	cd $(EXAMPLE) && $(DART) analyze lib test

format: ## dart format kit + example
	$(DART) format lib test $(EXAMPLE)/lib $(EXAMPLE)/test --line-length 80

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

ci: get gen analyze test get-example gen-example analyze-example test-example ## full local CI
	@echo "✅ kit + example: analyze and tests passed"

## ── Release (maintainer) ────────────────────────────────────────────────────
# make release VERSION=v0.2.0        → CHANGELOG + commit + annotated tag (no push)
# make release VERSION=v0.2.0 DRY=1  → preview the CHANGELOG entry only
release: ## CHANGELOG + tag for VERSION (DRY=1 to preview)
	@test -n "$(VERSION)" || { echo "Usage: make release VERSION=vX.Y.Z [DRY=1]"; exit 1; }
	@bash scripts/release.sh "$(VERSION)" $(if $(DRY),--dry,)
