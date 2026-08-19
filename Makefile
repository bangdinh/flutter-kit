.PHONY: get gen gen-watch clean analyze format test test-coverage run-dev run-stg run-prod feature rename ci

## Dependencies
get:
	flutter pub get

## Code Generation (freezed, json_serializable, riverpod_generator)
gen:
	dart run build_runner build --delete-conflicting-outputs

gen-watch:
	dart run build_runner watch --delete-conflicting-outputs

## Clean
clean:
	flutter clean
	rm -rf .dart_tool build
	flutter pub get

## Quality
analyze:
	flutter analyze

format:
	dart format lib/ test/ --line-length 80

## Test
test:
	flutter test

test-coverage:
	flutter test --coverage
	@echo "Open coverage/lcov.info with your IDE or genhtml"

## Run
run-dev:
	flutter run --dart-define=ENV=dev

run-stg:
	flutter run --dart-define=ENV=staging

run-prod:
	flutter run --dart-define=ENV=prod --release

## New Feature scaffold
# Usage: make feature NAME=profile
feature:
	@echo "Creating feature: $(NAME)"
	mkdir -p lib/features/$(NAME)/data/datasources
	mkdir -p lib/features/$(NAME)/data/models
	mkdir -p lib/features/$(NAME)/data/repositories
	mkdir -p lib/features/$(NAME)/domain/entities
	mkdir -p lib/features/$(NAME)/domain/repositories
	mkdir -p lib/features/$(NAME)/presentation/providers
	mkdir -p lib/features/$(NAME)/presentation/pages
	mkdir -p lib/features/$(NAME)/presentation/widgets
	@echo "✅ Feature $(NAME) created. See features/auth/ for reference."

## Rename project (fork kit for new app)
# Usage: make rename NAME=my_awesome_app
rename:
	./scripts/rename_project.sh $(NAME)

## CI — run locally what GitHub Actions runs
ci: get gen analyze format test
	@echo "✅ All CI checks passed"
