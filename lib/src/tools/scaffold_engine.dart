/// Template engine behind `bin/scaffold.dart` and `bin/new_feature.dart`.
///
/// Deliberately dependency-free (`dart:io` only): the scaffold must run from a
/// bare checkout of the kit, before anything is resolved.
library;

import 'dart:convert';
import 'dart:io';
import 'dart:isolate';

/// Placeholders are `__snake__` / `__Pascal__` tokens rather than mustache, so
/// a template file stays readable and `git diff`-able as source.
typedef TemplateVars = Map<String, String>;

/// Files a template ships that must not be substituted or renamed.
const _binaryExtensions = {
  '.png',
  '.jpg',
  '.jpeg',
  '.gif',
  '.webp',
  '.ico',
  '.ttf',
  '.otf',
  '.jar',
  '.keystore',
};

/// `foo_bar` — Dart package and file names.
String snakeCase(String input) {
  final cleaned =
      input
          .replaceAll(RegExp(r'[\s\-.]+'), '_')
          .replaceAllMapped(
            RegExp('([a-z0-9])([A-Z])'),
            (m) => '${m[1]}_${m[2]}',
          )
          .toLowerCase();
  return cleaned.replaceAll(RegExp('_+'), '_').replaceAll(RegExp(r'^_|_$'), '');
}

/// `FooBar` — class names.
String pascalCase(String input) =>
    snakeCase(input)
        .split('_')
        .where((part) => part.isNotEmpty)
        .map((part) => part[0].toUpperCase() + part.substring(1))
        .join();

/// `foo bar` — prose, e.g. a page title.
String titleWords(String input) => snakeCase(input).split('_').join(' ');

/// A Dart package name: lower_snake_case, starts with a letter, not a reserved
/// word. `flutter create` rejects anything else, so fail before it does.
String? validatePackageName(String name) {
  if (!RegExp(r'^[a-z][a-z0-9_]*$').hasMatch(name)) {
    return 'must be lower_snake_case, starting with a letter (got "$name")';
  }
  if (_dartReservedWords.contains(name)) {
    return '"$name" is a Dart reserved word';
  }
  return null;
}

/// Reverse-DNS, as Android/iOS bundle ids require.
String? validateOrg(String org) {
  if (!RegExp(r'^[a-z][a-z0-9_]*(\.[a-z][a-z0-9_]*)+$').hasMatch(org)) {
    return 'must be reverse-DNS like vn.fpt (got "$org")';
  }
  return null;
}

const _dartReservedWords = {
  'abstract',
  'as',
  'assert',
  'async',
  'await',
  'break',
  'case',
  'catch',
  'class',
  'const',
  'continue',
  'covariant',
  'default',
  'deferred',
  'do',
  'dynamic',
  'else',
  'enum',
  'export',
  'extends',
  'extension',
  'external',
  'factory',
  'false',
  'final',
  'finally',
  'for',
  'function',
  'get',
  'hide',
  'if',
  'implements',
  'import',
  'in',
  'interface',
  'is',
  'late',
  'library',
  'mixin',
  'new',
  'null',
  'on',
  'operator',
  'part',
  'required',
  'rethrow',
  'return',
  'sealed',
  'set',
  'show',
  'static',
  'super',
  'switch',
  'sync',
  'this',
  'throw',
  'true',
  'try',
  'typedef',
  'var',
  'void',
  'when',
  'while',
  'with',
  'yield',
  'test',
  'flutter',
};

/// Substitutes every `__token__` in [input]. An unknown token is left alone so
/// it shows up in the generated file instead of silently vanishing.
String applyVars(String input, TemplateVars vars) {
  var out = input;
  vars.forEach((key, value) => out = out.replaceAll(key, value));
  return out;
}

/// Result of a render, for tests and for the CLI summary.
class RenderReport {
  RenderReport();

  final List<String> written = [];
  final List<String> skipped = [];
}

/// Copies [from] onto [to], substituting placeholders in paths and in text
/// content, and stripping the `.tmpl` suffix.
///
/// `.tmpl` exists so template Dart files and pubspecs are invisible to the
/// analyzer and to pub in this repo — otherwise `dart analyze` would try to
/// resolve `package:__name__/...`.
RenderReport renderTemplate({
  required Directory from,
  required Directory to,
  required TemplateVars vars,
  bool overwrite = true,
  RenderReport? report,
}) {
  final result = report ?? RenderReport();

  if (!from.existsSync()) {
    throw ArgumentError('template directory not found: ${from.path}');
  }

  for (final entity in from.listSync(recursive: true).whereType<File>()) {
    final relative = entity.path.substring(from.path.length + 1);
    var targetRelative = applyVars(relative, vars);
    if (targetRelative.endsWith('.tmpl')) {
      targetRelative = targetRelative.substring(
        0,
        targetRelative.length - '.tmpl'.length,
      );
    }

    final target = File('${to.path}/$targetRelative');
    if (target.existsSync() && !overwrite) {
      result.skipped.add(targetRelative);
      continue;
    }

    target.parent.createSync(recursive: true);

    final isBinary = _binaryExtensions.any(entity.path.endsWith);
    if (isBinary) {
      entity.copySync(target.path);
    } else {
      target.writeAsStringSync(applyVars(entity.readAsStringSync(), vars));
    }
    result.written.add(targetRelative);
  }

  result.written.sort();
  result.skipped.sort();
  return result;
}

/// Locates the kit's own root (the directory holding `templates/`).
///
/// Three strategies, because this runs in three very different places: from a
/// kit checkout (`dart run bin/scaffold.dart`), from an app whose kit lives in
/// the pub cache (`dart run flutter_kit:new_feature`), and from `flutter test`.
Future<Directory> resolveKitRoot() async {
  // 1. package_config.json — works from any package that depends on the kit,
  //    including the kit itself, and is the only one `flutter test` supports.
  final fromConfig = _rootFromPackageConfig();
  if (fromConfig != null) return fromConfig;

  // 2. The isolate's own package resolution (plain `dart run`).
  try {
    final libUri = await Isolate.resolvePackageUri(
      Uri.parse('package:flutter_kit/flutter_kit.dart'),
    );
    if (libUri != null) {
      final root = Directory(File.fromUri(libUri).parent.parent.path);
      if (_hasTemplates(root)) return root;
    }
  } on UnsupportedError {
    // Unavailable in some runtimes (flutter_test) — fall through.
  }

  // 3. Walk up from the running script.
  var dir = File.fromUri(Platform.script).parent;
  for (var i = 0; i < 5; i++) {
    if (_hasTemplates(dir)) return dir;
    dir = dir.parent;
  }

  throw StateError(
    'cannot locate the kit templates/ directory — run this from a flutter_kit '
    'checkout, or from an app that depends on flutter_kit.',
  );
}

bool _hasTemplates(Directory dir) =>
    Directory('${dir.path}/templates/app').existsSync();

Directory? _rootFromPackageConfig() {
  var dir = Directory.current;
  for (var i = 0; i < 6; i++) {
    final config = File('${dir.path}/.dart_tool/package_config.json');
    if (config.existsSync()) {
      final root = _kitRootFrom(config);
      if (root != null) return root;
    }
    final parent = dir.parent;
    if (parent.path == dir.path) break;
    dir = parent;
  }
  return null;
}

Directory? _kitRootFrom(File packageConfig) {
  try {
    final json =
        jsonDecode(packageConfig.readAsStringSync()) as Map<String, dynamic>;
    final packages =
        (json['packages'] as List<dynamic>).cast<Map<String, dynamic>>();
    final kit = packages.firstWhere(
      (p) => p['name'] == 'flutter_kit',
      orElse: () => const <String, dynamic>{},
    );
    final rootUri = kit['rootUri'] as String?;
    if (rootUri == null) return null;

    // rootUri is relative to the .dart_tool directory.
    final resolved = packageConfig.parent.uri.resolve('$rootUri/');
    final root = Directory.fromUri(resolved);
    return _hasTemplates(root) ? root : null;
  } on Object {
    return null;
  }
}
