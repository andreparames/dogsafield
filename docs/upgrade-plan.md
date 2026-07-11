# Dependency Upgrade Plan

## connectivity_plus 6.1.5 → 7.2.0

**Files touched:** 2
- `lib/core/database/connectivity_service.dart`
- `test/core/database/connectivity_service_test.dart`

**Steps:**
- Update constraint in `pubspec.yaml`: `connectivity_plus: ^7.2.0`
- Run `flutter pub upgrade`
- Check for API changes (the stream-based API likely unchanged)
- Run tests

---

## drift 2.23.1 / drift_dev 2.23.1 / sqlparser 0.40.0 → 2.28.2 / 2.28.0 / 0.41.2

**Files touched:** ~6
- `lib/core/database/database.dart`
- `lib/core/database/tables.dart`
- `lib/core/database/local_cache_service.dart`
- `test/core/database/local_cache_service_test.dart`
- `test/helpers/test_utils.dart`

**Steps:**
- Update constraints in `pubspec.yaml`:
  - `drift: ^2.28.2`
  - `drift_dev: ^2.28.0`
  - `sqlparser: ^0.41.2`
- Run `flutter pub upgrade`
- Run `dart run build_runner build` to regenerate `.g.dart` files
- Check for any drift API changes in manual code
- Run tests

**Note:** drift 2.34 is also available (latest), but 2.28 is the first resolvable step.

---

## geolocator 13.0.4 → 14.0.2

**Files touched:** 5
- `lib/core/services/location_service.dart`
- `lib/core/services/location_provider.dart`
- `lib/features/field_map/presentation/field_map_screen.dart`
- `test/core/location_provider_test.dart`
- `test/features/field_map/field_map_providers_test.dart`

**Steps:**
- Update constraint in `pubspec.yaml`: `geolocator: ^14.0.2`
- Run `flutter pub upgrade`
- Check `LocationPermission`, `Position`, `LocationSettings` types for API changes
- Run tests

---

## go_router 14.8.1 → 17.0.0

**Files touched:** 27
- `lib/routes.dart`
- Feature route files: `onboarding/routes.dart`, `field_map/routes.dart`, `hosting/routes.dart`, `connections/routes.dart`, `account/routes.dart`, `messaging/routes.dart`, `info/routes.dart`, `verification_loop/routes.dart`
- Screen files using `context.go()`, `context.push()`, `context.pop()`
- Test helpers and test files

**Steps:**
- Update constraint in `pubspec.yaml`: `go_router: ^17.0.0`
- Run `flutter pub upgrade`
- Check CHANGELOG for breaking changes across 14→15→16→17
- Update route definitions and navigation calls
- Run tests

---

## flutter_riverpod 2.6.1 → 3.3.2

**Files touched:** 44

**Breaking changes:**
- `StateNotifier<T>` / `StateNotifierProvider` removed → use `Notifier<T>` / `NotifierProvider`
- `StateProvider` removed → use `NotifierProvider` or basic `Provider`
- `Override` type removed from test utilities → use `Override` from riverpod 3's new API
- `AsyncValue.valueOrNull` removed → use `.valueOrNull` (renamed/moved)

**Notifier classes to migrate:**
- `lib/features/account/state/account_providers.dart` — `AccountActionNotifier`
- `lib/features/connections/state/connection_providers.dart` — `ConnectionActionNotifier`
- `lib/features/field_map/state/rsvp_providers.dart` — `RsvpActionNotifier`
- `lib/features/hosting/state/hosting_provider.dart` — `HostingActionNotifier`
- `lib/features/onboarding/state/onboarding_state.dart` — `OnboardingNotifier`

**StateProviders to migrate:**
- `lib/features/onboarding/state/auth_provider.dart` — `signingInProvider`

**Provider declarations to migrate:**
- Every `StateNotifierProvider<...>` → `NotifierProvider<...>`
- `lib/features/field_map/state/field_map_providers.dart` — `selectedEventIdProvider` (StateProvider)

**Test files to update:**
- `test/helpers/test_utils.dart` — `List<Override>` → riverpod 3 override API
- All test files importing `flutter_riverpod`

**Steps:**
- Update constraint in `pubspec.yaml`: `flutter_riverpod: ^3.3.2`
- Run `flutter pub upgrade`
- Migrate all `StateNotifier` classes to `Notifier`
- Migrate all `StateNotifierProvider` to `NotifierProvider`
- Migrate `StateProvider` to appropriate replacement
- Update test overrides
- Run tests
