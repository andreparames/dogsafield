import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:dogsafield/features/field_map/state/rsvp_providers.dart';
import 'package:dogsafield/features/onboarding/state/auth_provider.dart';
import '../../helpers/test_utils.dart';

void main() {
  late FakeRsvpRepository repo;

  setUp(() {
    repo = FakeRsvpRepository();
  });

  group('hasRsvpProvider', () {
    test('returns false when user has not RSVPd', () async {
      final container = ProviderContainer(
        overrides: [
          authServiceProvider.overrideWithValue(fakeAuthService),
          authStateProvider.overrideWith((ref) => Stream.empty()),
          rsvpRepositoryProvider.overrideWithValue(repo),
        ],
      );
      addTearDown(container.dispose);

      final result = await container.read(hasRsvpProvider('evt-1').future);
      expect(result, false);
    });

    test('returns true after RSVP', () async {
      await repo.rsvpToEvent('evt-1');

      final container = ProviderContainer(
        overrides: [
          authServiceProvider.overrideWithValue(fakeAuthService),
          authStateProvider.overrideWith((ref) => Stream.empty()),
          rsvpRepositoryProvider.overrideWithValue(repo),
        ],
      );
      addTearDown(container.dispose);

      final result = await container.read(hasRsvpProvider('evt-1').future);
      expect(result, true);
    });
  });

  group('rsvpActionProvider', () {
    test('starts in idle state', () {
      final container = ProviderContainer(
        overrides: [
          authServiceProvider.overrideWithValue(fakeAuthService),
          authStateProvider.overrideWith((ref) => Stream.empty()),
          rsvpRepositoryProvider.overrideWithValue(repo),
        ],
      );
      addTearDown(container.dispose);

      expect(container.read(rsvpActionProvider('evt-1')), RsvpActionState.idle);
    });

    test('joinPack transitions to success', () async {
      final container = ProviderContainer(
        overrides: [
          authServiceProvider.overrideWithValue(fakeAuthService),
          authStateProvider.overrideWith((ref) => Stream.empty()),
          rsvpRepositoryProvider.overrideWithValue(repo),
        ],
      );
      addTearDown(container.dispose);

      final notifier = container.read(rsvpActionProvider('evt-1').notifier);
      await notifier.joinPack();

      expect(container.read(rsvpActionProvider('evt-1')), RsvpActionState.success);
      expect(await container.read(hasRsvpProvider('evt-1').future), true);
    });

    test('cancelRsvp transitions to success and removes RSVP', () async {
      await repo.rsvpToEvent('evt-1');

      final container = ProviderContainer(
        overrides: [
          authServiceProvider.overrideWithValue(fakeAuthService),
          authStateProvider.overrideWith((ref) => Stream.empty()),
          rsvpRepositoryProvider.overrideWithValue(repo),
        ],
      );
      addTearDown(container.dispose);

      final notifier = container.read(rsvpActionProvider('evt-1').notifier);
      await notifier.cancelRsvp();

      expect(container.read(rsvpActionProvider('evt-1')), RsvpActionState.success);
      expect(await container.read(hasRsvpProvider('evt-1').future), false);
    });

    test('joinPack transitions to error on failure', () async {
      repo.shouldFail = true;

      final container = ProviderContainer(
        overrides: [
          authServiceProvider.overrideWithValue(fakeAuthService),
          authStateProvider.overrideWith((ref) => Stream.empty()),
          rsvpRepositoryProvider.overrideWithValue(repo),
        ],
      );
      addTearDown(container.dispose);

      final notifier = container.read(rsvpActionProvider('evt-1').notifier);
      await notifier.joinPack();

      expect(container.read(rsvpActionProvider('evt-1')), RsvpActionState.error);
    });
  });
}
