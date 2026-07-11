import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:dogsafield/features/account/presentation/account_screen.dart';
import 'package:dogsafield/features/account/state/account_providers.dart';
import 'package:dogsafield/features/onboarding/state/auth_provider.dart';
import 'package:dogsafield/i18n/strings.g.dart';
import 'package:dogsafield/shared/models/dog.dart';
import 'package:dogsafield/shared/models/user_profile.dart';
import '../../helpers/test_utils.dart';

Widget createAccountApp(AccountDetail detail) {
  LocaleSettings.setLocaleSync(AppLocale.en);
  final router = GoRouter(
    initialLocation: '/test',
    routes: [
      GoRoute(path: '/test', builder: (_, __) => const AccountScreen()),
      GoRoute(path: '/account/upgrade', builder: (_, __) => const SizedBox()),
    ],
  );

  return ProviderScope(
    overrides: [
      authServiceProvider.overrideWithValue(fakeAuthService),
      authStateProvider.overrideWith((ref) => Stream.empty()),
      accountDetailProvider.overrideWith((ref) => Future.value(detail)),
    ],
    child: TranslationProvider(
      child: MaterialApp.router(routerConfig: router),
    ),
  );
}

void main() {
  group('AccountScreen', () {
    testWidgets('displays profile header with display name and email', (tester) async {
      await tester.pumpWidget(createAccountApp(
        AccountDetail(
          profile: UserProfile(
            id: 'u1',
            email: 'alice@example.com',
            displayName: 'Alice',
            photoUrl: 'https://example.com/photo.jpg',
          ),
        ),
      ));
      await tester.pumpAndSettle();

      expect(find.text('Alice'), findsOneWidget);
      expect(find.text('alice@example.com'), findsOneWidget);
    });

    testWidgets('displays Unknown when displayName is null', (tester) async {
      await tester.pumpWidget(createAccountApp(
        AccountDetail(
          profile: UserProfile(id: 'u1', email: 'bob@example.com'),
        ),
      ));
      await tester.pumpAndSettle();

      expect(find.text(t.common.unknown), findsOneWidget);
      expect(find.text('bob@example.com'), findsOneWidget);
    });

    testWidgets('displays dog info when dog is present', (tester) async {
      await tester.pumpWidget(createAccountApp(
        AccountDetail(
          profile: UserProfile(id: 'u1', email: 'a@b.com', displayName: 'Alice'),
          dog: Dog(id: 'd1', ownerId: 'u1', name: 'Buddy', breed: 'Labrador', vibe: SocialVibe.zoomieKing),
        ),
      ));
      await tester.pumpAndSettle();

      expect(find.text('Buddy'), findsOneWidget);
      expect(find.text('Labrador'), findsOneWidget);
      expect(find.text('Zoomie King'), findsOneWidget);
    });

    testWidgets('displays trial RSVP section', (tester) async {
      await tester.pumpWidget(createAccountApp(
        AccountDetail(
          profile: UserProfile(
            id: 'u1',
            email: 'a@b.com',
            displayName: 'Alice',
            trialRsvpsUsed: 1,
          ),
        ),
      ));
      await tester.pumpAndSettle();

      expect(find.text(t.account.trialRsvps), findsOneWidget);
    });

    testWidgets('shows upgrade button when trial exhausted', (tester) async {
      await tester.pumpWidget(createAccountApp(
        AccountDetail(
          profile: UserProfile(
            id: 'u1',
            email: 'a@b.com',
            displayName: 'Alice',
            trialRsvpsUsed: 3,
          ),
        ),
      ));
      await tester.pumpAndSettle();

      expect(find.text(t.account.upgradeToKeepJoining), findsOneWidget);
    });

    testWidgets('displays Founding Pack section', (tester) async {
      await tester.pumpWidget(createAccountApp(
        AccountDetail(
          profile: UserProfile(
            id: 'u1',
            email: 'a@b.com',
            displayName: 'Alice',
            isFoundingPack: true,
          ),
        ),
      ));
      await tester.pumpAndSettle();

      expect(find.text(t.account.foundingPack.badge), findsOneWidget);
    });

    testWidgets('displays safety section when treat policy is set', (tester) async {
      await tester.pumpWidget(createAccountApp(
        AccountDetail(
          profile: UserProfile(
            id: 'u1',
            email: 'a@b.com',
            displayName: 'Alice',
            treatPolicy: TreatPolicy.okToShare,
          ),
        ),
      ));
      await tester.pumpAndSettle();

      expect(find.text(t.account.safetyBoundaries), findsOneWidget);
      expect(find.text(t.treatPolicy.okToShareDetail), findsOneWidget);
    });

    testWidgets('shows error state on failure', (tester) async {
      final router = GoRouter(
        initialLocation: '/test',
        routes: [
          GoRoute(path: '/test', builder: (_, __) => const AccountScreen()),
        ],
      );

      await tester.pumpWidget(ProviderScope(
        overrides: [
          authServiceProvider.overrideWithValue(fakeAuthService),
          authStateProvider.overrideWith((ref) => Stream.empty()),
          accountDetailProvider.overrideWith((ref) => Future.error(Exception('fail'))),
        ],
        child: TranslationProvider(
          child: MaterialApp.router(routerConfig: router),
        ),
      ));
      await tester.pumpAndSettle();

      expect(find.text(t.account.couldNotLoad), findsOneWidget);
      expect(find.text(t.common.retry), findsOneWidget);
    });

    testWidgets('shows loading indicator initially', (tester) async {
      final router = GoRouter(
        initialLocation: '/test',
        routes: [
          GoRoute(path: '/test', builder: (_, __) => const AccountScreen()),
        ],
      );

      await tester.pumpWidget(ProviderScope(
        overrides: [
          authServiceProvider.overrideWithValue(fakeAuthService),
          authStateProvider.overrideWith((ref) => Stream.empty()),
        ],
        child: TranslationProvider(
          child: MaterialApp.router(routerConfig: router),
        ),
      ));

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('displays dog icebreaker answer', (tester) async {
      await tester.pumpWidget(createAccountApp(
        AccountDetail(
          profile: UserProfile(id: 'u1', email: 'a@b.com', displayName: 'Alice'),
          dog: Dog(id: 'd1', ownerId: 'u1', name: 'Buddy', icebreakerAnswer: 'He ate my shoe'),
        ),
      ));
      await tester.pumpAndSettle();

      expect(find.text('\u201CHe ate my shoe\u201D'), findsOneWidget);
    });

    testWidgets('displays ask before feeding when treat policy set', (tester) async {
      await tester.pumpWidget(createAccountApp(
        AccountDetail(
          profile: UserProfile(
            id: 'u1',
            email: 'a@b.com',
            displayName: 'Alice',
            treatPolicy: TreatPolicy.askBeforeFeeding,
          ),
        ),
      ));
      await tester.pumpAndSettle();

      expect(find.text(t.treatPolicy.askBeforeFeedingDetail), findsOneWidget);
    });
  });
}
