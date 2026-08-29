import 'dart:io';

import 'package:flutter_kit/src/tools/scaffold_engine.dart';
import 'package:flutter_test/flutter_test.dart';

Directory _tempDir() {
  final dir = Directory.systemTemp.createTempSync('flutter_kit_scaffold_');
  addTearDown(() => dir.deleteSync(recursive: true));
  return dir;
}

void main() {
  group('case helpers', () {
    test('snakeCase normalises anything a human might type', () {
      expect(snakeCase('CameraB2b'), 'camera_b2b');
      expect(snakeCase('camera-b2b'), 'camera_b2b');
      expect(snakeCase('camera b2b'), 'camera_b2b');
      expect(snakeCase('camera__b2b'), 'camera_b2b');
    });

    test('pascalCase builds a class name', () {
      expect(pascalCase('camera_b2b'), 'CameraB2b');
      expect(pascalCase('profile'), 'Profile');
    });

    test('titleWords builds prose', () {
      expect(titleWords('camera_b2b'), 'camera b2b');
    });
  });

  group('validation', () {
    test('accepts a valid package name', () {
      expect(validatePackageName('camera_b2b'), isNull);
    });

    test('rejects what flutter create would reject', () {
      expect(validatePackageName('CameraB2b'), isNotNull); // upper case
      expect(validatePackageName('2fast'), isNotNull); // leading digit
      expect(validatePackageName('my-app'), isNotNull); // dash
      expect(validatePackageName('class'), isNotNull); // reserved word
    });

    test('requires a reverse-DNS org', () {
      expect(validateOrg('vn.fpt'), isNull);
      expect(validateOrg('com.example.app'), isNull);
      expect(validateOrg('fpt'), isNotNull); // no dot
      expect(validateOrg('VN.FPT'), isNotNull); // upper case
    });
  });

  group('renderTemplate', () {
    test('substitutes in content and in paths, and strips .tmpl', () {
      final from = _tempDir();
      final to = _tempDir();
      File('${from.path}/lib/__name__/__Name__Page.dart.tmpl')
        ..parent.createSync(recursive: true)
        ..writeAsStringSync('class __Name__Page {} // __name__');

      final report = renderTemplate(
        from: from,
        to: to,
        vars: {'__name__': 'demo_app', '__Name__': 'DemoApp'},
      );

      expect(report.written, ['lib/demo_app/DemoAppPage.dart']);
      expect(
        File('${to.path}/lib/demo_app/DemoAppPage.dart').readAsStringSync(),
        'class DemoAppPage {} // demo_app',
      );
    });

    test('leaves an unknown placeholder visible rather than blanking it', () {
      final from = _tempDir();
      final to = _tempDir();
      File('${from.path}/a.txt').writeAsStringSync('__name__ __unknown__');

      renderTemplate(from: from, to: to, vars: {'__name__': 'x'});

      expect(File('${to.path}/a.txt').readAsStringSync(), 'x __unknown__');
    });

    test('overwrite: false keeps an existing file and reports it', () {
      final from = _tempDir();
      final to = _tempDir();
      File('${from.path}/keep.txt').writeAsStringSync('from template');
      File('${to.path}/keep.txt').writeAsStringSync('hand-written');

      final report = renderTemplate(
        from: from,
        to: to,
        vars: const {},
        overwrite: false,
      );

      expect(report.skipped, ['keep.txt']);
      expect(report.written, isEmpty);
      expect(File('${to.path}/keep.txt').readAsStringSync(), 'hand-written');
    });

    test('fails loudly on a missing template directory', () {
      expect(
        () => renderTemplate(
          from: Directory('${_tempDir().path}/nope'),
          to: _tempDir(),
          vars: const {},
        ),
        throwsArgumentError,
      );
    });
  });

  group('shipped templates', () {
    late Directory kitRoot;

    setUpAll(() async => kitRoot = await resolveKitRoot());

    test('resolveKitRoot finds templates/', () {
      expect(Directory('${kitRoot.path}/templates/app').existsSync(), isTrue);
      expect(
        Directory('${kitRoot.path}/templates/feature').existsSync(),
        isTrue,
      );
    });

    test('the app template renders with no placeholder left behind', () {
      final to = _tempDir();
      renderTemplate(
        from: Directory('${kitRoot.path}/templates/app'),
        to: to,
        vars: {
          '__name__': 'demo_app',
          '__Name__': 'DemoApp',
          '__title__': 'Demo App',
          '__org__': 'vn.fpt',
          '__description__': 'A demo.',
          '__kit_dependency__': 'flutter_kit:\n    path: ../',
          '__kit_ref__': 'v0.1.0',
        },
      );

      final leftovers =
          to
              .listSync(recursive: true)
              .whereType<File>()
              .where(
                (f) => RegExp('__[a-zA-Z_]+__').hasMatch(f.readAsStringSync()),
              )
              .map((f) => f.path.substring(to.path.length + 1))
              .toList();

      expect(leftovers, isEmpty, reason: 'unsubstituted placeholders remain');
      expect(File('${to.path}/pubspec.yaml').existsSync(), isTrue);
      expect(File('${to.path}/lib/main.dart').existsSync(), isTrue);
      // The skills a generated app must carry. feature-flow and git-flow are
      // app-only; flutter-arch and flutter-testing are the shared standards
      // (make verify-skill proves those two are byte-identical to the kit's).
      for (final skill in [
        'feature-flow',
        'flutter-arch',
        'flutter-testing',
        'git-flow',
      ]) {
        expect(
          File('${to.path}/.claude/skills/$skill/SKILL.md').existsSync(),
          isTrue,
          reason: '$skill must ship with a generated app',
        );
      }

      // Kit-only skills would be noise in an app: it has no templates/ and no
      // public API to widen.
      for (final skill in ['kit-scaffold', 'kit-extension-point']) {
        expect(
          File('${to.path}/.claude/skills/$skill/SKILL.md').existsSync(),
          isFalse,
          reason: '$skill is kit-only',
        );
      }
    });

    test('the feature template renders a full three-layer folder', () {
      final to = _tempDir();
      final report = renderTemplate(
        from: Directory('${kitRoot.path}/templates/feature'),
        to: to,
        vars: {
          '__feature__': 'profile',
          '__Feature__': 'Profile',
          '__features__': 'profiles',
          '__title__': 'profile',
          '__name__': 'demo_app',
        },
      );

      expect(
        report.written,
        containsAll([
          'lib/features/profile/domain/entities/profile.dart',
          'lib/features/profile/domain/repositories/profile_repository.dart',
          'lib/features/profile/data/models/profile_model.dart',
          'lib/features/profile/data/datasources/profile_remote_data_source.dart',
          'lib/features/profile/data/repositories/profile_repository_impl.dart',
          'lib/features/profile/presentation/providers/profile_provider.dart',
          'lib/features/profile/presentation/pages/profile_page.dart',
          'test/features/profile/data/fake_profile_repository.dart',
          'test/features/profile/presentation/profile_provider_test.dart',
        ]),
      );

      // The domain layer must stay pure — this is the rule most likely to rot.
      final entity =
          File(
            '${to.path}/lib/features/profile/domain/entities/profile.dart',
          ).readAsStringSync();
      expect(entity, isNot(contains('package:flutter/')));
      expect(entity, isNot(contains('package:dio/')));
    });
  });
}
