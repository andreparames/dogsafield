import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dogsafield/features/connections/state/connection_providers.dart';
import 'package:dogsafield/features/onboarding/state/auth_provider.dart';
import '../../helpers/test_utils.dart';

void main() {
  group('ConnectionActionNotifier', () {
    test('blockUser transitions through states on success', () async {
      final repo = FakeConnectionRepository();
      final container = ProviderContainer(
        overrides: [
          authServiceProvider.overrideWithValue(fakeAuthService),
          authStateProvider.overrideWith((ref) => Stream.empty()),
          connectionRepositoryProvider.overrideWithValue(repo),
        ],
      );
      addTearDown(container.dispose);

      final notifier = container.read(connectionActionProvider.notifier);
      expect(container.read(connectionActionProvider), isA<ConnectionActionIdle>());

      notifier.blockUser('target');
      expect(container.read(connectionActionProvider), isA<ConnectionActionLoading>());

      await Future<void>.delayed(Duration.zero);
      expect(container.read(connectionActionProvider), isA<ConnectionActionSuccess>());
      expect(repo.blockCallCount, 1);
    });

    test('blockUser transitions to error on failure', () async {
      final repo = FakeConnectionRepository()..shouldFail = true;
      final container = ProviderContainer(
        overrides: [
          authServiceProvider.overrideWithValue(fakeAuthService),
          authStateProvider.overrideWith((ref) => Stream.empty()),
          connectionRepositoryProvider.overrideWithValue(repo),
        ],
      );
      addTearDown(container.dispose);

      final notifier = container.read(connectionActionProvider.notifier);

      notifier.blockUser('target');
      await Future<void>.delayed(Duration.zero);

      final state = container.read(connectionActionProvider);
      expect(state, isA<ConnectionActionError>());
      expect((state as ConnectionActionError).message, contains('Failed to block user'));
    });

    test('unblockUser transitions through states on success', () async {
      final repo = FakeConnectionRepository();
      final container = ProviderContainer(
        overrides: [
          authServiceProvider.overrideWithValue(fakeAuthService),
          authStateProvider.overrideWith((ref) => Stream.empty()),
          connectionRepositoryProvider.overrideWithValue(repo),
        ],
      );
      addTearDown(container.dispose);

      final notifier = container.read(connectionActionProvider.notifier);
      expect(container.read(connectionActionProvider), isA<ConnectionActionIdle>());

      notifier.unblockUser('target');
      expect(container.read(connectionActionProvider), isA<ConnectionActionLoading>());

      await Future<void>.delayed(Duration.zero);
      expect(container.read(connectionActionProvider), isA<ConnectionActionSuccess>());
      expect(repo.unblockCallCount, 1);
    });

    test('re-entrancy guard prevents concurrent calls', () async {
      final repo = FakeConnectionRepository();
      final container = ProviderContainer(
        overrides: [
          authServiceProvider.overrideWithValue(fakeAuthService),
          authStateProvider.overrideWith((ref) => Stream.empty()),
          connectionRepositoryProvider.overrideWithValue(repo),
        ],
      );
      addTearDown(container.dispose);

      final notifier = container.read(connectionActionProvider.notifier);

      notifier.blockUser('target');
      notifier.blockUser('target2');

      await Future<void>.delayed(Duration.zero);
      expect(repo.blockCallCount, 1);
    });

    test('reset returns to idle', () async {
      final repo = FakeConnectionRepository();
      final container = ProviderContainer(
        overrides: [
          authServiceProvider.overrideWithValue(fakeAuthService),
          authStateProvider.overrideWith((ref) => Stream.empty()),
          connectionRepositoryProvider.overrideWithValue(repo),
        ],
      );
      addTearDown(container.dispose);

      final notifier = container.read(connectionActionProvider.notifier);
      notifier.reset();
      expect(container.read(connectionActionProvider), isA<ConnectionActionIdle>());
    });
  });

  group('blockedUsersProvider', () {
    test('returns empty list when no blocks exist', () async {
      final repo = FakeConnectionRepository();
      repo.blockedUsers = [];
      final container = ProviderContainer(
        overrides: [
          authServiceProvider.overrideWithValue(fakeAuthService),
          authStateProvider.overrideWith((ref) => Stream.empty()),
          connectionRepositoryProvider.overrideWithValue(repo),
        ],
      );
      addTearDown(container.dispose);

      final blocked = await container.read(blockedUsersProvider.future);
      expect(blocked, isEmpty);
    });
  });
}