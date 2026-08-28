import 'package:flutter/material.dart';
import 'package:flutter_kit_example/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:flutter_kit_example/features/auth/presentation/pages/login_page.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../data/fake_auth_repository.dart';

/// Widget test — Andrea's tip #19: Robot testing pattern.
///
/// The "robot" is a helper that wraps finder calls for readable tests.
void main() {
  late FakeAuthRepository fakeRepo;

  Widget createWidget() {
    return ProviderScope(
      overrides: [authRepositoryProvider.overrideWithValue(fakeRepo)],
      child: const MaterialApp(home: LoginPage()),
    );
  }

  setUp(() {
    fakeRepo = FakeAuthRepository();
  });

  group('LoginPage', () {
    testWidgets('renders email and password fields', (tester) async {
      await tester.pumpWidget(createWidget());
      await tester.pumpAndSettle(); // wait for async provider

      expect(find.text('Email'), findsOneWidget);
      expect(find.text('Password'), findsOneWidget);
      expect(find.text('Sign In'), findsOneWidget);
      expect(find.text('Flutter Kit'), findsOneWidget);
    });

    testWidgets('shows validation errors on empty submit', (tester) async {
      await tester.pumpWidget(createWidget());
      await tester.pumpAndSettle(); // wait for async provider

      // Tap sign in without filling fields
      await tester.tap(find.text('Sign In'));
      await tester.pumpAndSettle();

      expect(find.text('Email is required'), findsOneWidget);
      expect(find.text('Password is required'), findsOneWidget);
    });

    testWidgets('shows email validation error for invalid email', (
      tester,
    ) async {
      await tester.pumpWidget(createWidget());

      // Enter invalid email
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Email'),
        'not-an-email',
      );
      await tester.tap(find.text('Sign In'));
      await tester.pumpAndSettle();

      expect(find.text('Enter a valid email'), findsOneWidget);
    });

    testWidgets('shows password length error', (tester) async {
      await tester.pumpWidget(createWidget());

      await tester.enterText(
        find.widgetWithText(TextFormField, 'Email'),
        'test@test.com',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Password'),
        '123',
      );
      await tester.tap(find.text('Sign In'));
      await tester.pumpAndSettle();

      expect(
        find.text('Password must be at least 6 characters'),
        findsOneWidget,
      );
    });

    testWidgets('toggles password visibility', (tester) async {
      await tester.pumpWidget(createWidget());

      // Initially obscured — check via the underlying EditableText
      EditableText findPasswordEditable() {
        return tester.widget<EditableText>(
          find.descendant(
            of: find.widgetWithText(TextFormField, 'Password'),
            matching: find.byType(EditableText),
          ),
        );
      }

      expect(findPasswordEditable().obscureText, isTrue);

      // Tap visibility toggle
      await tester.tap(find.byIcon(Icons.visibility_outlined));
      await tester.pump();

      // Now visible
      expect(findPasswordEditable().obscureText, isFalse);
    });

    testWidgets('calls login on valid submit', (tester) async {
      await tester.pumpWidget(createWidget());

      // Fill valid data
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Email'),
        'test@example.com',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Password'),
        'password123',
      );

      // Submit
      await tester.tap(find.text('Sign In'));
      await tester.pumpAndSettle();

      expect(fakeRepo.loginCallCount, 1);
    });
  });
}
