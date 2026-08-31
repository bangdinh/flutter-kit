#!/usr/bin/env dart

/// Generates a new app on flutter_kit.
///
///   dart run bin/scaffold.dart --name my_app --org vn.fpt --out ../my_app
///
/// Platform folders (android/, ios/) come from `flutter create`, not from a
/// template: bundle ids, Kotlin package paths and Gradle files are the kind of
/// thing that rots the moment Flutter changes its template. The kit only
/// overlays what it actually owns — pubspec, lints, lib/, test/, docs, skills,
/// Makefile, CI.
library;

import 'dart:io';

import 'package:flutter_kit/src/tools/scaffold_engine.dart';

const _usage = '''
Usage: dart run bin/scaffold.dart --name <app_name> [options]

Required:
  --name <snake_case>     Dart package name of the app, e.g. camera_b2b

Options:
  --org <reverse.dns>     Bundle id prefix (default: vn.fpt)
  --out <dir>             Output directory (default: ../<name>)
  --description <text>    pubspec description
  --kit-ref <vX.Y.Z>      flutter_kit tag to pin (default: latest tag here)
  --local                 Depend on this kit by path instead of a tag (DEV only)
  --platforms <list>      Passed to flutter create (default: android,ios)
  --no-pub                Skip `flutter pub get`
  --no-gen                Skip `dart run build_runner build`
  -h, --help              This message
''';

Future<void> main(List<String> argv) async {
  final args = _parseArgs(argv);
  if (args.containsKey('help')) {
    stdout.write(_usage);
    return;
  }

  final name = args['name'];
  if (name == null || name.isEmpty) {
    _fail('--name is required.\n\n$_usage');
  }
  final nameError = validatePackageName(name);
  if (nameError != null) _fail('--name $nameError');

  final org = args['org'] ?? 'vn.fpt';
  final orgError = validateOrg(org);
  if (orgError != null) _fail('--org $orgError');

  final kitRoot = await resolveKitRoot();
  final out = Directory(args['out'] ?? '../$name');
  if (out.existsSync() && out.listSync().isNotEmpty) {
    _fail(
      '${out.path} already exists and is not empty — refusing to overwrite.',
    );
  }

  final local = args.containsKey('local');
  final kitRef = args['kit-ref'] ?? _latestTag(kitRoot);
  if (!local && kitRef == null) {
    _fail(
      'no git tag found in ${kitRoot.path}, so there is nothing to pin.\n'
      'Pass --kit-ref vX.Y.Z, or --local for a path dependency (DEV only).',
    );
  }

  final platforms = args['platforms'] ?? 'android,ios';
  final description =
      args['description'] ?? 'A Flutter app built on flutter_kit.';

  stdout.writeln('▸ flutter create ($platforms)');
  final created = await Process.run('flutter', [
    'create',
    '--project-name',
    name,
    '--org',
    org,
    '--platforms',
    platforms,
    '--description',
    description,
    out.path,
  ]);
  if (created.exitCode != 0) {
    _fail('flutter create failed:\n${created.stderr}\n${created.stdout}');
  }

  stdout.writeln('▸ overlaying kit templates');
  final report = renderTemplate(
    from: Directory('${kitRoot.path}/templates/app'),
    to: out,
    vars: {
      '__name__': name,
      '__Name__': pascalCase(name),
      '__title__': titleWords(name)
          .split(' ')
          .map((w) => w.isEmpty ? w : w[0].toUpperCase() + w.substring(1))
          .join(' '),
      '__org__': org,
      '__description__': description,
      '__kit_dependency__':
          local
              ? 'flutter_kit:\n    path: ${kitRoot.absolute.path}'
              : 'flutter_kit:\n'
                  '    git:\n'
                  '      url: git@github.com:bangdinh/flutter-kit.git\n'
                  '      ref: $kitRef',
      '__kit_ref__': local ? 'path:${kitRoot.absolute.path}' : kitRef!,
    },
  );
  stdout.writeln('  ${report.written.length} files written');

  // `flutter create` leaves a sample widget test that references the counter
  // app it also wrote; both are replaced by the template, but its own
  // widget_test.dart name would linger next to ours.
  final stale = File('${out.path}/test/widget_test.dart');
  if (stale.existsSync()) stale.deleteSync();

  if (!args.containsKey('no-pub')) {
    stdout.writeln('▸ flutter pub get');
    final pub = await Process.run('flutter', [
      'pub',
      'get',
    ], workingDirectory: out.path);
    if (pub.exitCode != 0) {
      stderr.writeln('  pub get failed — fix pubspec.yaml, then rerun:');
      stderr.writeln('  ${pub.stderr}');
    } else if (!args.containsKey('no-gen')) {
      stdout.writeln('▸ build_runner');
      final gen = await Process.run('dart', [
        'run',
        'build_runner',
        'build',
      ], workingDirectory: out.path);
      if (gen.exitCode != 0) {
        stderr.writeln('  codegen failed (env files may be missing):');
        stderr.writeln('  ${gen.stdout}');
      }
    }
  }

  stdout.writeln('''

✓ ${out.path} created — flutter_kit ${local ? '(local path)' : kitRef}

Next:
  cd ${out.path}
  cp .env.example .env.dev && cp .env.example .env.staging && cp .env.example .env.prod
  \$EDITOR .env.dev            # set API_BASE_URL per environment
  make gen && make ci          # codegen, analyze, test
  make run-dev

  git init && git add -A && git commit -m "chore: scaffold $name from flutter_kit ${kitRef ?? 'local'}"

Read CLAUDE.md in the new app: it points at the kit docs and ships the
feature-flow / flutter-arch / git-flow skills.
''');
}

String? _latestTag(Directory kitRoot) {
  final result = Process.runSync('git', [
    'describe',
    '--tags',
    '--abbrev=0',
  ], workingDirectory: kitRoot.path);
  if (result.exitCode != 0) return null;
  final tag = (result.stdout as String).trim();
  return tag.isEmpty ? null : tag;
}

Map<String, String> _parseArgs(List<String> argv) {
  final args = <String, String>{};
  for (var i = 0; i < argv.length; i++) {
    final arg = argv[i];
    if (arg == '-h' || arg == '--help') {
      args['help'] = '';
      continue;
    }
    if (!arg.startsWith('--')) _fail('unexpected argument "$arg"\n\n$_usage');
    final key = arg.substring(2);
    const flags = {'local', 'no-pub', 'no-gen'};
    if (flags.contains(key)) {
      args[key] = '';
      continue;
    }
    if (i + 1 >= argv.length) _fail('--$key needs a value\n\n$_usage');
    args[key] = argv[++i];
  }
  return args;
}

Never _fail(String message) {
  stderr.writeln('ERROR: $message');
  exit(1);
}
