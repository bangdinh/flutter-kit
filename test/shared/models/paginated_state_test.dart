import 'package:flutter_kit/shared/models/paginated_state.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('PaginatedState', () {
    test('initial state has sensible defaults', () {
      const state = PaginatedState<String>();

      expect(state.items, isEmpty);
      expect(state.page, 1);
      expect(state.isLoadingMore, isFalse);
      expect(state.hasMore, isTrue);
      expect(state.error, isNull);
      expect(state.isEmpty, isTrue);
    });

    test('appendPage adds items and increments page', () {
      const state = PaginatedState<String>(
        items: ['a', 'b'],
        page: 1,
      );

      final next = state.appendPage(['c', 'd'], hasMore: true);

      expect(next.items, ['a', 'b', 'c', 'd']);
      expect(next.page, 2);
      expect(next.hasMore, isTrue);
      expect(next.isLoadingMore, isFalse);
    });

    test('appendPage with hasMore=false marks end', () {
      const state = PaginatedState<int>(items: [1], page: 1);
      final next = state.appendPage([2], hasMore: false);

      expect(next.hasMore, isFalse);
      expect(next.items, [1, 2]);
    });

    test('reset returns to initial state', () {
      const state = PaginatedState<int>(
        items: [1, 2, 3],
        page: 3,
        hasMore: false,
      );

      final reset = state.reset();

      expect(reset.items, isEmpty);
      expect(reset.page, 1);
      expect(reset.hasMore, isTrue);
    });

    test('copyWith clearError removes error', () {
      final state = PaginatedState<int>(
        items: const [1],
        error: Exception('fail'),
      );

      expect(state.error, isNotNull);

      final cleared = state.copyWith(clearError: true);
      expect(cleared.error, isNull);
      expect(cleared.items, [1]);
    });
  });
}
