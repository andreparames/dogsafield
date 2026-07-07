import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:dogsafield/features/field_map/data/field_map_repository.dart';
import 'package:dogsafield/features/field_map/data/gathering_detail.dart';
import 'package:dogsafield/features/field_map/data/gathering_repository.dart';
import 'package:dogsafield/features/field_map/data/rsvp_repository.dart';
import 'package:dogsafield/features/hosting/data/hosting_repository.dart';
import 'package:dogsafield/features/onboarding/data/auth_service.dart';
import 'package:dogsafield/features/onboarding/data/onboarding_repository.dart';
import 'package:dogsafield/features/onboarding/state/auth_provider.dart';
import 'package:dogsafield/shared/models/dog.dart';
import 'package:dogsafield/shared/models/event.dart';
import 'package:dogsafield/shared/models/user_profile.dart';

class FakeAuthService extends AuthService {
  FakeAuthService() : super.test();

  bool _isAuthenticatedOverride = false;
  User? _currentUserOverride;

  void setAuthenticated({required bool value, User? user}) {
    _isAuthenticatedOverride = value;
    _currentUserOverride = user;
  }

  @override
  User? get currentUser => _currentUserOverride;

  @override
  bool get isAuthenticated => _isAuthenticatedOverride;

  @override
  Future<void> signInWithApple() async {}

  @override
  Future<void> signInWithGoogle() async {}

  @override
  Future<void> signOut() async {}
}

class FakeOnboardingRepository implements OnboardingRepository {
  bool shouldFail = false;
  int uploadCallCount = 0;
  UserProfile? existingProfile;

  @override
  Future<String> uploadPhoto(String path) async {
    uploadCallCount++;
    if (shouldFail) throw Exception('Upload failed');
    return 'https://example.com/uploaded.jpg';
  }

  @override
  Future<UserProfile?> fetchProfile(String id) async => existingProfile;

  @override
  Future<UserProfile> createProfile(UserProfile profile) async {
    if (shouldFail) throw Exception('Profile save failed');
    return profile;
  }

  @override
  Future<Dog> createDogProfile(Dog dog) async {
    if (shouldFail) throw Exception('Dog save failed');
    return dog;
  }
}

class FakeHostingRepository implements HostingRepository {
  bool shouldFail = false;
  int createCallCount = 0;
  DogEvent? lastCreated;

  @override
  Future<DogEvent> createEvent(DogEvent event) async {
    createCallCount++;
    if (shouldFail) throw Exception('Create failed');
    lastCreated = event;
    return event;
  }

  @override
  Future<List<DogEvent>> fetchMyEvents() async {
    return [];
  }
}

class FakeFieldMapRepository implements FieldMapRepository {
  List<DogEvent> nearbyEvents = [];
  List<DogEvent> rsvpEvents = [];
  bool shouldFail = false;

  @override
  Future<List<DogEvent>> fetchEventsNearby({
    required double latitude,
    required double longitude,
    double radiusKm = 50,
  }) async {
    if (shouldFail) throw Exception('Fetch failed');
    return nearbyEvents;
  }

  @override
  Future<List<DogEvent>> fetchMyRsvps() async {
    if (shouldFail) throw Exception('Fetch failed');
    return rsvpEvents;
  }
}

class FakeGatheringRepository implements GatheringRepository {
  GatheringDetail? detail;
  bool shouldFail = false;

  @override
  Future<GatheringDetail> fetchGatheringDetail(String eventId) async {
    if (shouldFail) throw Exception('Gathering fetch failed');
    if (detail == null) throw Exception('Not found');
    return detail!;
  }
}

class FakeRsvpRepository implements RsvpRepository {
  Set<String> rsvpEvents = {};
  bool shouldFail = false;

  @override
  Future<void> rsvpToEvent(String eventId) async {
    if (shouldFail) throw Exception('RSVP failed');
    rsvpEvents.add(eventId);
  }

  @override
  Future<void> cancelRsvp(String eventId) async {
    if (shouldFail) throw Exception('Cancel failed');
    rsvpEvents.remove(eventId);
  }

  @override
  Future<bool> hasRsvp(String eventId) async {
    if (shouldFail) throw Exception('Check failed');
    return rsvpEvents.contains(eventId);
  }
}

final fakeAuthService = FakeAuthService();
final fakeOnboardingRepository = FakeOnboardingRepository();

Widget createTestApp(Widget child) {
  final router = GoRouter(
    initialLocation: '/test',
    routes: [
      GoRoute(path: '/test', builder: (_, __) => child),
      GoRoute(path: '/onboarding/welcome', builder: (_, __) => const SizedBox()),
      GoRoute(path: '/onboarding/photo', builder: (_, __) => const SizedBox()),
      GoRoute(path: '/onboarding/profile', builder: (_, __) => const SizedBox()),
      GoRoute(path: '/onboarding/icebreaker', builder: (_, __) => const SizedBox()),
      GoRoute(path: '/onboarding/safety', builder: (_, __) => const SizedBox()),
      GoRoute(path: '/', builder: (_, __) => const SizedBox()),
    ],
  );
  return ProviderScope(
    overrides: [
      authServiceProvider.overrideWithValue(fakeAuthService),
      authStateProvider.overrideWith((ref) => Stream.empty()),
      onboardingRepositoryProvider.overrideWithValue(fakeOnboardingRepository),
    ],
    child: MaterialApp.router(routerConfig: router),
  );
}
