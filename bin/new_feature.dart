#!/usr/bin/env dart

/// Scaffolds one feature folder inside an app built on flutter_kit.
///
///   dart run flutter_kit:new_feature profile        # from the app root
///   make feature NAME=profile
///
/// Generates the full data/domain/presentation skeleton that `flutter-arch`
/// requires, so the structure is never the thing that drifts.
library;

import 'dart:io';

import 'package:flutter_kit/src/tools/scaffold_engine.dart';

Future<void> main(List<String> argv) async {
  final positional = argv.where((a) => !a.startsWith('-')).toList();
  if (positional.isEmpty || argv.contains('-h') || argv.contains('--help')) {
    stdout.writeln('Usage: dart run flutter_kit:new_feature <feature_name>');
    stdout.writeln('       (run from the app root, next to pubspec.yaml)');
    return;
  }

  final raw = positional.first;
  final feature = snakeCase(raw);
  final error = validatePackageName(feature);
  if (error != null) {
    stderr.writeln('ERROR: feature name $error');
    exit(1);
  }

  final appRoot = Directory.current;
  final pubspec = File('${appRoot.path}/pubspec.yaml');
  if (!pubspec.existsSync()) {
    stderr.writeln('ERROR: no pubspec.yaml here — run this from the app root.');
    exit(1);
  }
  final appName = RegExp(
    r'^name:\s*(\S+)',
    multiLine: true,
  ).firstMatch(pubspec.readAsStringSync())?.group(1);
  if (appName == null) {
    stderr.writeln('ERROR: cannot read the app name from pubspec.yaml.');
    exit(1);
  }

  final target = Directory('${appRoot.path}/lib/features/$feature');
  if (target.existsSync()) {
    stderr.writeln('ERROR: lib/features/$feature already exists.');
    exit(1);
  }

  final kitRoot = await resolveKitRoot();
  final report = renderTemplate(
    from: Directory('${kitRoot.path}/templates/feature'),
    to: appRoot,
    vars: {
      '__feature__': feature,
      '__Feature__': pascalCase(feature),
      '__features__': _pluralize(feature),
      '__title__': titleWords(feature),
      '__name__': appName,
    },
    overwrite: false,
  );

  for (final path in report.written) {
    stdout.writeln('  + $path');
  }
  for (final path in report.skipped) {
    stdout.writeln('  = $path (exists, left alone)');
  }

  stdout.writeln('''

✓ feature "$feature" created

Next:
  1. make gen                       # freezed + riverpod for the new files
  2. fix the endpoint in lib/features/$feature/data/datasources/ — the template
     guesses "/${_pluralize(feature)}"
  3. add a route in lib/app/router/route_paths.dart + app_router.dart
  4. write the test first: test/features/$feature/
''');
}

/// Naive plural for the guessed endpoint path — the generated file says so and
/// tells the developer to correct it.
String _pluralize(String word) {
  if (word.endsWith('s') || word.endsWith('x') || word.endsWith('ch')) {
    return '${word}es';
  }
  if (word.endsWith('y') && word.length > 1) {
    return '${word.substring(0, word.length - 1)}ies';
  }
  return '${word}s';
}
