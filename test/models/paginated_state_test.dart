import 'package:flutter_kit/flutter_kit.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('PaginatedState', () {
    test('starts empty but willing to load', () {
      const state = PaginatedState<String>();

      expect(state.items, isEmpty);
      expect(state.isEmpty, isTrue);
      expect(state.nextCursor, isNull);
      expect(state.isLoadingMore, isFalse);
      expect(
        state.hasMore,
        isTrue,
        reason: 'the first load must be allowed before the server has spoken',
      );
    });

    test('appendPage adds items and advances the cursor', () {
      const state = PaginatedState<String>(items: ['a'], nextCursor: 'c1');

      final next = state.appendPage(['b'], hasMore: true, nextCursor: 'c2');

      expect(next.items, ['a', 'b']);
      expect(next.nextCursor, 'c2');
      expect(next.hasMore, isTrue);
      expect(next.isLoadingMore, isFalse);
    });

    test('the last page clears hasMore and the cursor', () {
      const state = PaginatedState<String>(items: ['a'], nextCursor: 'c1');

      final next = state.appendPage(['b'], hasMore: false);

      expect(next.hasMore, isFalse);
      expect(next.nextCursor, isNull);
    });

    test('keeps total across pages when the server sent one', () {
      const state = PaginatedState<String>(items: ['a'], total: 3);

      final next = state.appendPage(['b'], hasMore: false);

      expect(next.total, 3);
    });

    test('reset returns to the initial state', () {
      const state = PaginatedState<String>(
        items: ['a'],
        nextCursor: 'c1',
        hasMore: false,
        error: 'boom',
      );

      final reset = state.reset();

      expect(reset.items, isEmpty);
      expect(reset.nextCursor, isNull);
      expect(reset.hasMore, isTrue);
      expect(reset.error, isNull);
    });

    test('copyWith clears the error and the cursor on request', () {
      const state = PaginatedState<String>(nextCursor: 'c1', error: 'boom');

      expect(state.copyWith(clearError: true).error, isNull);
      expect(state.copyWith(clearCursor: true).nextCursor, isNull);
      expect(state.copyWith(isLoadingMore: true).nextCursor, 'c1');
    });
  });
}
