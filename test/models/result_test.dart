import 'package:flutter_kit/flutter_kit.dart';
import 'package:flutter_test/flutter_test.dart';

/// Tests for the sealed [Result] type.
///
/// Andrea's tip #48: Testing functions that throw
/// — test both success and failure paths explicitly.
void main() {
  group('Result', () {
    group('Success', () {
      test('holds data', () {
        final result = Result.success(42);

        switch (result) {
          case Success(:final data):
            expect(data, 42);
          case Failure():
            fail('Expected Success');
        }
      });

      test('dataOrNull returns data', () {
        final result = Result.success('hello');
        expect(result.dataOrNull, 'hello');
      });

      test('map transforms data', () {
        final result = Result.success(10);
        final mapped = result.map((data) => data * 2);

        expect(mapped.dataOrNull, 20);
      });

      test('mapAsync transforms data', () async {
        final result = Result.success(5);
        final mapped = await result.mapAsync((data) async => data + 1);

        expect(mapped.dataOrNull, 6);
      });
    });

    group('Failure', () {
      test('holds exception', () {
        final exception = Exception('something went wrong');
        final result = Result<int>.failure(exception);

        switch (result) {
          case Success():
            fail('Expected Failure');
          case Failure(:final exception):
            expect(exception.toString(), contains('something went wrong'));
        }
      });

      test('dataOrNull returns null', () {
        final result = Result<String>.failure(Exception('error'));
        expect(result.dataOrNull, isNull);
      });

      test('map propagates failure', () {
        final result = Result<int>.failure(Exception('error'));
        final mapped = result.map((data) => data * 2);

        expect(mapped.dataOrNull, isNull);
        expect(mapped, isA<Failure<int>>());
      });
    });

    group('pattern matching', () {
      test('works with switch expression', () {
        final Result<String> result = Result.success('dart');

        final message = switch (result) {
          Success(:final data) => 'Got: $data',
          Failure(:final exception) => 'Error: $exception',
        };

        expect(message, 'Got: dart');
      });
    });
  });
}
