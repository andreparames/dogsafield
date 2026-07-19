import 'dart:async';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:dogsafield/core/database/database.dart';
import 'package:dogsafield/core/database/local_cache_service.dart';
import 'package:dogsafield/core/database/providers.dart';
import 'package:dogsafield/features/account/data/account_repository.dart';
import 'package:dogsafield/features/account/state/account_providers.dart';
import 'package:dogsafield/features/connections/data/connection_repository.dart';
import 'package:dogsafield/features/connections/state/connection_providers.dart';
import 'package:dogsafield/features/field_map/data/field_map_repository.dart';
import 'package:dogsafield/features/field_map/data/gathering_detail.dart';
import 'package:dogsafield/features/field_map/data/gathering_repository.dart';
import 'package:dogsafield/features/field_map/data/rsvp_repository.dart';
import 'package:dogsafield/features/field_map/data/waitlist_repository.dart';
import 'package:dogsafield/features/hosting/data/hosting_repository.dart';
import 'package:dogsafield/features/messaging/data/messaging_repository.dart';
import 'package:dogsafield/features/messaging/data/conversation.dart';
import 'package:dogsafield/features/messaging/data/message.dart';
import 'package:dogsafield/features/onboarding/data/auth_service.dart';
import 'package:dogsafield/features/onboarding/data/onboarding_repository.dart';
import 'package:dogsafield/features/onboarding/state/auth_provider.dart';
import 'package:dogsafield/features/field_map/data/region_repository.dart';
import 'package:dogsafield/i18n/strings.g.dart';
import 'package:dogsafield/shared/models/dog.dart';
import 'package:dogsafield/shared/models/event.dart';
import 'package:dogsafield/shared/models/region.dart';
import 'package:dogsafield/shared/models/user_profile.dart';

class FakeAccountRepository implements AccountRepository {
  bool shouldFail = false;
  int fieldIntroSeenCount = 0;
  int hostIntroSeenCount = 0;
  UserProfile? profile;
  final List<Dog> dogs = [];

  @override
  Future<UserProfile> fetchProfile(String userId) async {
    if (shouldFail) throw Exception('Fetch failed');
    return profile ?? UserProfile(id: userId, email: 'test@test.com');
  }

  @override
  Future<List<Dog>> fetchDogs(String ownerId) async => dogs;

  @override
  Future<void> updateProfile(String userId, Map<String, dynamic> fields) async {
    if (shouldFail) throw Exception('Update failed');
    if (profile != null) {
      profile = profile!.copyWith(
        displayName: fields['display_name'] as String? ?? profile!.displayName,
        photoUrl: fields['photo_url'] as String? ?? profile!.photoUrl,
        treatPolicy: fields['treat_policy'] != null
            ? TreatPolicy.values.firstWhere((e) => e.name == fields['treat_policy'])
            : profile!.treatPolicy,
      );
    }
  }

  @override
  Future<void> updateDog(String dogId, Map<String, dynamic> fields) async {
    if (shouldFail) throw Exception('Update failed');
    final index = dogs.indexWhere((d) => d.id == dogId);
    if (index != -1) {
      dogs[index] = dogs[index].copyWith(
        name: fields['name'] as String? ?? dogs[index].name,
        age: fields['age'] as int? ?? dogs[index].age,
        breed: fields['breed'] as String? ?? dogs[index].breed,
        vibe: fields['vibe'] != null
            ? SocialVibe.values.firstWhere((e) => e.name == fields['vibe'])
            : null,
        icebreakerAnswer: fields['icebreaker_answer'] as String? ?? dogs[index].icebreakerAnswer,
      );
    }
  }

  @override
  Future<void> addDog(Map<String, dynamic> fields) async {
    if (shouldFail) throw Exception('Add failed');
    dogs.add(Dog(
      id: fields['id'] as String,
      ownerId: fields['owner_id'] as String,
      name: fields['name'] as String,
      age: fields['age'] as int?,
      breed: fields['breed'] as String?,
      vibe: fields['vibe'] != null
          ? SocialVibe.values.firstWhere((e) => e.name == fields['vibe'])
          : null,
      icebreakerAnswer: fields['icebreaker_answer'] as String?,
    ));
  }

  @override
  Future<void> deleteDog(String dogId) async {
    if (shouldFail) throw Exception('Delete failed');
    dogs.removeWhere((d) => d.id == dogId);
  }

  @override
  Future<String> uploadDogPhoto(String dogId, String localPath) async {
    if (shouldFail) throw Exception('Upload failed');
    return 'https://example.com/dog_photos/$dogId/photo.jpg';
  }

  @override
  Future<void> removeDogPhoto(String dogId) async {
    if (shouldFail) throw Exception('Remove failed');
  }

  @override
  Future<void> suspendAccount() async {
    if (shouldFail) throw Exception('Suspend failed');
  }

  @override
  Future<void> reactivateAccount() async {
    if (shouldFail) throw Exception('Reactivate failed');
  }

  @override
  Future<void> deleteAccount() async {
    if (shouldFail) throw Exception('Delete failed');
  }

  @override
  Future<void> markFieldIntroSeen(String userId) async {
    fieldIntroSeenCount++;
    if (shouldFail) throw Exception('Mark failed');
  }

  @override
  Future<void> markHostIntroSeen(String userId) async {
    hostIntroSeenCount++;
    if (shouldFail) throw Exception('Mark failed');
  }
}

class FakeAuthService extends AuthService {
  FakeAuthService() : super.test();

  bool _isAuthenticatedOverride = false;
  User? _currentUserOverride;

  /// When non-null, [validateReviewerCode] returns this for any code.
  /// When null, the method returns null (invalid code).
  String? reviewerEmailForCode;

  /// If true, [signInWithEmailPassword] throws.
  bool signInShouldFail = false;

  String? lastSignInEmail;
  String? lastSignInPassword;

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

  @override
  Future<void> signInWithEmailPassword(String email, String password) async {
    lastSignInEmail = email;
    lastSignInPassword = password;
    if (signInShouldFail) throw Exception('Sign-in failed');
  }

  @override
  Future<String?> validateReviewerCode(String code) async {
    return reviewerEmailForCode;
  }
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
  int updateCallCount = 0;
  int cancelCallCount = 0;
  DogEvent? lastCreated;
  DogEvent? lastUpdated;
  List<DogEvent> myEvents = [];
  List<Map<String, dynamic>> attendees = [];
  bool? lastCancelledId;

  @override
  Future<DogEvent> createEvent(DogEvent event) async {
    createCallCount++;
    if (shouldFail) throw Exception('Create failed');
    lastCreated = event;
    return event;
  }

  @override
  Future<DogEvent> updateEvent(DogEvent event) async {
    updateCallCount++;
    if (shouldFail) throw Exception('Update failed');
    lastUpdated = event;
    return event;
  }

  @override
  Future<void> cancelEvent(String eventId) async {
    cancelCallCount++;
    if (shouldFail) throw Exception('Cancel failed');
    lastCancelledId = true;
    myEvents = myEvents.map((e) => e.id == eventId ? e.copyWith(isCancelled: true) : e).toList();
  }

  @override
  Future<List<DogEvent>> fetchMyEvents() async {
    if (shouldFail) throw Exception('Fetch failed');
    return myEvents;
  }

  @override
  Future<List<Map<String, dynamic>>> fetchAttendees(String eventId) async {
    if (shouldFail) throw Exception('Fetch failed');
    return attendees;
  }

  @override
  Future<void> removeAttendee(String eventId, String userId) async {
    if (shouldFail) throw Exception('Remove failed');
    attendees.removeWhere((a) => a['user_id'] == userId);
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
  Future<Set<String>> fetchMyRsvpIds() async {
    if (shouldFail) throw Exception('Fetch failed');
    return rsvpEvents;
  }

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

class FakeWaitlistRepository implements WaitlistRepository {
  final Map<String, WaitlistEntry> _entries = {};
  bool shouldFail = false;

  @override
  Future<WaitlistEntry> joinWaitlist(String walkId) async {
    if (shouldFail) throw Exception('Join failed');
    final entry = WaitlistEntry(
      id: 'wl-${walkId}',
      walkId: walkId,
      userId: 'current-user',
      status: 'waiting',
      createdAt: DateTime.now(),
    );
    _entries[walkId] = entry;
    return entry;
  }

  @override
  Future<void> confirmSpot(String walkId) async {
    if (shouldFail) throw Exception('Confirm failed');
    final existing = _entries[walkId];
    if (existing == null) throw Exception('Not on waitlist');
    _entries[walkId] = WaitlistEntry(
      id: existing.id,
      walkId: existing.walkId,
      userId: existing.userId,
      status: 'confirmed',
      confirmedAt: DateTime.now(),
      createdAt: existing.createdAt,
    );
  }

  @override
  Future<void> leaveWaitlist(String walkId) async {
    if (shouldFail) throw Exception('Leave failed');
    _entries.remove(walkId);
  }

  @override
  Future<WaitlistEntry?> fetchMyStatus(String walkId) async {
    if (shouldFail) throw Exception('Fetch failed');
    return _entries[walkId];
  }

  @override
  Future<Map<String, int>> fetchCounts(String walkId) async {
    if (shouldFail) throw Exception('Fetch failed');
    final entry = _entries[walkId];
    if (entry == null) return {'waiting': 0, 'confirmed': 0, 'released': 0};
    if (entry.status == 'confirmed') {
      return {'waiting': 0, 'confirmed': 1, 'released': 0};
    }
    return {'waiting': 1, 'confirmed': 0, 'released': 0};
  }
}

class FakeConnectionRepository implements ConnectionRepository {
  bool shouldFail = false;
  int blockCallCount = 0;
  int unblockCallCount = 0;
  List<Map<String, dynamic>> blockedUsers = [];

  @override
  Future<void> setBlockTier(String targetUserId, int tier, {String? reportReason}) async {
    if (shouldFail) throw Exception('Block failed');
    if (tier == 0) {
      unblockCallCount++;
    } else {
      blockCallCount++;
    }
  }

  @override
  Future<List<Map<String, dynamic>>> fetchBlockedUsers() async {
    if (shouldFail) throw Exception('Fetch failed');
    return blockedUsers;
  }

  @override
  Future<List<Map<String, dynamic>>> fetchBlockers() async {
    if (shouldFail) throw Exception('Fetch failed');
    return [];
  }
}

class FakeRegionRepository implements RegionRepository {
  List<Region> regions = [];
  bool shouldFail = false;

  @override
  Future<List<Region>> fetchEnabledRegions() async {
    if (shouldFail) throw Exception('Fetch failed');
    return regions;
  }
}

class FakeMessagingRepository implements MessagingRepository {
  bool shouldFail = false;
  bool canMessageResult = true;
  List<Conversation> conversations = [];
  List<Message> messages = [];
  int sendMessageCallCount = 0;
  int markAsReadCallCount = 0;
  String? lastSentConversationId;
  String? lastSentContent;

  @override
  Future<List<Conversation>> fetchConversations() async {
    if (shouldFail) throw Exception('Fetch failed');
    return conversations;
  }

  @override
  Stream<List<Message>> streamMessages(String conversationId) async* {
    yield messages.where((m) => m.conversationId == conversationId).toList();
  }

  @override
  Stream<List<Conversation>> streamConversations() async* {
    yield conversations;
  }

  @override
  Future<Conversation> getOrCreateConversation(String otherUserId) async {
    if (shouldFail) throw Exception('Failed to get conversation');
    final existing = conversations.where((c) => c.otherUserId == otherUserId);
    if (existing.isNotEmpty) return existing.first;
    final newConvo = Conversation(
      id: 'new-convo-$otherUserId',
      otherUserId: otherUserId,
      otherUserName: 'Test User',
      lastMessageAt: DateTime.now(),
    );
    conversations = [...conversations, newConvo];
    return newConvo;
  }

  @override
  Future<Message> sendMessage(
    String conversationId,
    String content, {
    MessageType messageType = MessageType.text,
    Map<String, dynamic>? payload,
  }) async {
    if (shouldFail) throw Exception('Send failed');
    sendMessageCallCount++;
    lastSentConversationId = conversationId;
    lastSentContent = content;
    final message = Message(
      id: 'msg-${messages.length + 1}',
      conversationId: conversationId,
      senderId: 'current-user',
      content: content,
      createdAt: DateTime.now(),
      messageType: messageType,
      payload: payload,
    );
    messages = [...messages, message];
    return message;
  }

  @override
  Future<void> sendEventEditedNotification(
    String hostId,
    String eventId,
    String eventTitle,
    List<String> attendeeIds,
  ) async {
    if (shouldFail) throw Exception('Send failed');
  }

  @override
  Future<void> sendEventLeftNotification(
    String attendeeId,
    String attendeeName,
    String eventId,
    String eventTitle,
    String hostId,
  ) async {
    if (shouldFail) throw Exception('Send failed');
  }

  @override
  Future<void> sendAccountSuspendedNotification(String userId) async {
    if (shouldFail) throw Exception('Send failed');
  }

  @override
  Future<void> markAsRead(String conversationId) async {
    if (shouldFail) throw Exception('Mark as read failed');
    markAsReadCallCount++;
  }

  @override
  Future<bool> canMessageUser(String targetUserId) async {
    if (shouldFail) throw Exception('Check failed');
    return canMessageResult;
  }
}

Future<ProviderContainer> createContainerWithCache({
  List<dynamic> additionalOverrides = const [],
}) async {
  SharedPreferences.setMockInitialValues({});
  final prefs = await SharedPreferences.getInstance();
  final db = AppDatabase(executor: NativeDatabase.memory());
  final cache = LocalCacheService(db: db, prefs: prefs);
  final container = ProviderContainer(
    overrides: [
      sharedPreferencesProvider.overrideWithValue(prefs),
      localDatabaseProvider.overrideWithValue(db),
      localCacheServiceProvider.overrideWithValue(cache),
      authServiceProvider.overrideWithValue(fakeAuthService),
      authStateProvider.overrideWith((ref) => Stream.empty()),
      // Note: onboardingRepositoryProvider is no longer overridden by default.
      // Pass it via additionalOverrides when onboarding behavior is under test.
      ...additionalOverrides,
    ],
  );
  return container;
}

final fakeAuthService = FakeAuthService();
final fakeOnboardingRepository = FakeOnboardingRepository();
final fakeAccountRepository = FakeAccountRepository();
final fakeConnectionRepository = FakeConnectionRepository();
final fakeMessagingRepository = FakeMessagingRepository();
final fakeRegionRepository = FakeRegionRepository();

Widget createTestApp(Widget child) {
  LocaleSettings.setLocaleSync(AppLocale.en);
  final router = GoRouter(
    initialLocation: '/test',
    routes: [
      GoRoute(path: '/test', builder: (_, __) => child),
      GoRoute(path: '/onboarding/welcome', builder: (_, __) => const SizedBox()),
      GoRoute(path: '/onboarding/reviewer-login', name: 'reviewerLogin', builder: (_, __) => const Scaffold(body: Text('Reviewer Login'))),
      GoRoute(path: '/onboarding/photo', builder: (_, __) => const SizedBox()),
      GoRoute(path: '/onboarding/profile', builder: (_, __) => const SizedBox()),
      GoRoute(path: '/onboarding/icebreaker', builder: (_, __) => const SizedBox()),
      GoRoute(path: '/onboarding/safety', builder: (_, __) => const SizedBox()),
      GoRoute(path: '/hosting/responsibility', builder: (_, __) => const SizedBox()),
      GoRoute(path: '/hosting/create', builder: (_, __) => const SizedBox()),
      GoRoute(path: '/field/intro', builder: (_, __) => const SizedBox()),
      GoRoute(path: '/', builder: (_, __) => const SizedBox()),
      GoRoute(path: '/connections/blocked', builder: (_, __) => const SizedBox()),
      GoRoute(path: '/messaging', builder: (_, __) => const SizedBox()),
      GoRoute(path: '/messaging/chat/:conversationId', builder: (_, __) => const SizedBox()),
    ],
  );
  return ProviderScope(
    overrides: [
      authServiceProvider.overrideWithValue(fakeAuthService),
      authStateProvider.overrideWith((ref) => Stream.empty()),
      onboardingRepositoryProvider.overrideWithValue(fakeOnboardingRepository),
      accountRepositoryProvider.overrideWithValue(fakeAccountRepository),
      connectionRepositoryProvider.overrideWithValue(fakeConnectionRepository),
    ],
    child: TranslationProvider(
      child: MaterialApp.router(routerConfig: router),
    ),
  );
}
