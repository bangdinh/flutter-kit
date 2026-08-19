#!/bin/bash
set -euo pipefail

# =============================================================================
# Rename Flutter Kit to your project name.
#
# Usage:
#   ./scripts/rename_project.sh my_awesome_app
#
# What it does:
#   1. Renames package in pubspec.yaml
#   2. Updates all imports from 'flutter_kit' to your name
#   3. Updates Android package name placeholder
#   4. Updates iOS bundle identifier placeholder
# =============================================================================

NEW_NAME="${1:-}"

if [ -z "$NEW_NAME" ]; then
  echo "❌ Usage: $0 <new_project_name>"
  echo "   Example: $0 my_awesome_app"
  exit 1
fi

# Validate: lowercase, underscores only
if ! echo "$NEW_NAME" | grep -qE '^[a-z][a-z0-9_]*$'; then
  echo "❌ Project name must be lowercase with underscores only."
  echo "   Example: my_awesome_app"
  exit 1
fi

OLD_NAME="flutter_kit"
PROJECT_DIR="$(cd "$(dirname "$0")/.." && pwd)"

echo "🔄 Renaming: $OLD_NAME → $NEW_NAME"
echo "   Directory: $PROJECT_DIR"
echo ""

# 1. pubspec.yaml
echo "📦 Updating pubspec.yaml..."
sed -i '' "s/^name: $OLD_NAME/name: $NEW_NAME/" "$PROJECT_DIR/pubspec.yaml"

# 2. All Dart imports
echo "📝 Updating Dart imports..."
find "$PROJECT_DIR/lib" "$PROJECT_DIR/test" -name "*.dart" -type f | while read -r file; do
  sed -i '' "s|package:$OLD_NAME/|package:$NEW_NAME/|g" "$file"
done

# 3. README title
echo "📖 Updating README..."
sed -i '' "s/# Flutter Kit/# ${NEW_NAME//_/ }/" "$PROJECT_DIR/README.md"

# 4. App title in app.dart
echo "📱 Updating app title..."
sed -i '' "s/title: 'Flutter Kit'/title: '${NEW_NAME//_/ }'/" "$PROJECT_DIR/lib/app/app.dart"

echo ""
echo "✅ Done! Next steps:"
echo "   1. Run: flutter pub get"
echo "   2. Run: dart run build_runner build --delete-conflicting-outputs"
echo "   3. Update Android package name in android/app/build.gradle"
echo "   4. Update iOS bundle identifier in ios/Runner.xcodeproj"
echo "   5. Update colors in lib/app/theme/app_colors.dart"
echo "   6. Update API URLs in lib/app/env/app_env.dart"
