import 'package:flutter_kit/flutter_kit.dart';
import 'package:flutter_test/flutter_test.dart';

/// Shapes copied from b2b-gokit's `response` package tests, so a change on
/// either side shows up here.
void main() {
  group('ApiData', () {
    test('unwraps {"data": {...}}', () {
      final data = ApiData<Map<String, dynamic>>.fromJson({
        'data': {'id': 'res_123', 'displayName': 'Example'},
      }, (json) => json! as Map<String, dynamic>);

      expect(data.data['id'], 'res_123');
    });

    test('accepts a null payload (204-style body with an explicit null)', () {
      final data = ApiData<Object?>.fromJson({'data': null}, (json) => json);

      expect(data.data, isNull);
    });

    test('throws when the envelope is missing entirely', () {
      expect(
        () => ApiData<Object?>.fromJson({'id': 'x'}, (json) => json),
        throwsFormatException,
      );
    });
  });

  group('ApiPage', () {
    test('unwraps items and cursor page meta', () {
      final page = ApiPage<String>.fromJson({
        'data': ['a', 'b'],
        'page': {'limit': 50, 'nextCursor': 'eyJpZCI6', 'hasMore': true},
      }, (json) => json! as String);

      expect(page.items, ['a', 'b']);
      expect(page.page.limit, 50);
      expect(page.nextCursor, 'eyJpZCI6');
      expect(page.hasMore, isTrue);
      expect(page.page.total, isNull, reason: 'total is optional in gokit');
    });

    test('an empty collection is data: [] — not an error', () {
      final page = ApiPage<String>.fromJson({
        'data': <dynamic>[],
        'page': {'limit': 50, 'hasMore': false},
      }, (json) => json! as String);

      expect(page.items, isEmpty);
      expect(page.hasMore, isFalse);
    });

    test('reads total when the service could compute it', () {
      final page = ApiPage<String>.fromJson({
        'data': ['a'],
        'page': {'limit': 10, 'hasMore': false, 'total': 3},
      }, (json) => json! as String);

      expect(page.page.total, 3);
    });

    test('tolerates a missing page object', () {
      final page = ApiPage<String>.fromJson({
        'data': ['a'],
      }, (json) => json! as String);

      expect(page.hasMore, isFalse);
      expect(page.nextCursor, isNull);
    });

    test('treats an empty nextCursor as no cursor', () {
      // gokit omits nextCursor when empty, but a proxy may send "".
      final page = ApiPage<String>.fromJson({
        'data': ['a'],
        'page': {'nextCursor': '', 'hasMore': false},
      }, (json) => json! as String);

      expect(page.nextCursor, isNull);
    });

    test('rejects a single-resource envelope', () {
      expect(
        () => ApiPage<String>.fromJson({
          'data': {'id': 'x'},
        }, (json) => json! as String),
        throwsFormatException,
      );
    });
  });
}
