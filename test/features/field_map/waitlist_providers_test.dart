import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:dogsafield/features/field_map/state/waitlist_providers.dart';
import 'package:dogsafield/features/onboarding/state/auth_provider.dart';
import '../../helpers/test_utils.dart';

void main() {
  late FakeWaitlistRepository repo;

  setUp(() {
    repo = FakeWaitlistRepository();
  });

  group('myWaitlistStatusProvider', () {
    test('returns null when user has not joined', () async {
      final container = ProviderContainer(
        overrides: [
          authServiceProvider.overrideWithValue(fakeAuthService),
          authStateProvider.overrideWith((ref) => Stream.empty()),
          waitlistRepositoryProvider.overrideWithValue(repo),
        ],
      );
      addTearDown(container.dispose);

      final result = await container.read(myWaitlistStatusProvider('walk-1').future);
      expect(result, isNull);
    });

    test('returns entry after joining', () async {
      await repo.joinWaitlist('walk-1');

      final container = ProviderContainer(
        overrides: [
          authServiceProvider.overrideWithValue(fakeAuthService),
          authStateProvider.overrideWith((ref) => Stream.empty()),
          waitlistRepositoryProvider.overrideWithValue(repo),
        ],
      );
      addTearDown(container.dispose);

      final result = await container.read(myWaitlistStatusProvider('walk-1').future);
      expect(result, isNotNull);
      expect(result!.status, 'waiting');
    });
  });

  group('waitlistActionProvider', () {
    test('starts in idle state', () {
      final container = ProviderContainer(
        overrides: [
          authServiceProvider.overrideWithValue(fakeAuthService),
          authStateProvider.overrideWith((ref) => Stream.empty()),
          waitlistRepositoryProvider.overrideWithValue(repo),
        ],
      );
      addTearDown(container.dispose);

      expect(container.read(waitlistActionProvider('walk-1')), isA<WaitlistActionIdle>());
    });

    test('joinWaitlist transitions to success', () async {
      final container = ProviderContainer(
        overrides: [
          authServiceProvider.overrideWithValue(fakeAuthService),
          authStateProvider.overrideWith((ref) => Stream.empty()),
          waitlistRepositoryProvider.overrideWithValue(repo),
        ],
      );
      addTearDown(container.dispose);

      final notifier = container.read(waitlistActionProvider('walk-1').notifier);
      await notifier.joinWaitlist();

      expect(container.read(waitlistActionProvider('walk-1')), isA<WaitlistActionSuccess>());
      final entry = await container.read(myWaitlistStatusProvider('walk-1').future);
      expect(entry, isNotNull);
    });

    test('confirmSpot transitions to success', () async {
      await repo.joinWaitlist('walk-1');

      final container = ProviderContainer(
        overrides: [
          authServiceProvider.overrideWithValue(fakeAuthService),
          authStateProvider.overrideWith((ref) => Stream.empty()),
          waitlistRepositoryProvider.overrideWithValue(repo),
        ],
      );
      addTearDown(container.dispose);

      final notifier = container.read(waitlistActionProvider('walk-1').notifier);
      await notifier.confirmSpot();

      expect(container.read(waitlistActionProvider('walk-1')), isA<WaitlistActionSuccess>());
      final entry = await container.read(myWaitlistStatusProvider('walk-1').future);
      expect(entry?.status, 'confirmed');
    });

    test('leaveWaitlist transitions to success', () async {
      await repo.joinWaitlist('walk-1');

      final container = ProviderContainer(
        overrides: [
          authServiceProvider.overrideWithValue(fakeAuthService),
          authStateProvider.overrideWith((ref) => Stream.empty()),
          waitlistRepositoryProvider.overrideWithValue(repo),
        ],
      );
      addTearDown(container.dispose);

      final notifier = container.read(waitlistActionProvider('walk-1').notifier);
      await notifier.leaveWaitlist();

      expect(container.read(waitlistActionProvider('walk-1')), isA<WaitlistActionSuccess>());
      expect(await container.read(myWaitlistStatusProvider('walk-1').future), isNull);
    });

    test('joinWaitlist transitions to error on failure', () async {
      repo.shouldFail = true;

      final container = ProviderContainer(
        overrides: [
          authServiceProvider.overrideWithValue(fakeAuthService),
          authStateProvider.overrideWith((ref) => Stream.empty()),
          waitlistRepositoryProvider.overrideWithValue(repo),
        ],
      );
      addTearDown(container.dispose);

      final notifier = container.read(waitlistActionProvider('walk-1').notifier);
      await notifier.joinWaitlist();

      expect(container.read(waitlistActionProvider('walk-1')), isA<WaitlistActionError>());
    });
  });
}
