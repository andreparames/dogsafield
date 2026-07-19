# Dependency Upgrade Plan — Completed

## connectivity_plus 6.1.5 → 7.2.0

**Result:** No code changes needed. 4 tests pass.

---

## drift 2.23.1 / drift_dev 2.23.1 / sqlparser 0.40.0 → 2.28.2 / 2.28.0 / 0.41.2

**Result:** No manual code changes. `.g.dart` regenerated via `build_runner`. 22 tests pass.

---

## geolocator 13.0.4 → 14.0.2

**Result:** No code changes needed. 10 tests pass.

---

## go_router 14.8.1 → 17.0.0

**Result:** No code changes needed (backward-compatible API). 170 tests pass.

---

## flutter_riverpod 2.6.1 → 3.3.2

**Result:** Major migration required. See notes below.

### Migrations performed

**`StateNotifier<T>` → `Notifier<T>` with `build()`:**
- `AccountActionNotifier` — `account_providers.dart`
- `ConnectionActionNotifier` — `connection_providers.dart`
- `RsvpActionNotifier` — `rsvp_providers.dart`
- `HostingActionNotifier` — `hosting_provider.dart`
- `OnboardingNotifier` — `onboarding_state.dart`
- `SigningInNotifier` (new) — `auth_provider.dart` (replaces `StateProvider<bool>`)
- `RollCallActionNotifier` — `verification_providers.dart`
- `PackmateSyncNotifier` — `verification_providers.dart`

**`StateNotifierProvider<...>` → `NotifierProvider<...>`:**
- All provider declarations updated to use `NotifierProvider` / `NotifierProvider.family`
- Family argument passed as constructor parameter instead of family mixin

**`StateProvider<bool>` replacements:**
- `signingInProvider` → `SigningInNotifier` with `set()` method
- `rsvpFilterProvider` → `RsvpFilterNotifier` with `set()` method

**`AsyncValue.valueOrNull` → `.value`:**
- Updated in `field_map_providers.dart` and `my_events_screen.dart`

**Riverpod 3 API changes in tests:**
- `overrideWithProvider` → `overrideWith` (takes callable instead of provider)
- `Override` type not exported from public API — use `List<dynamic>` in test helpers
- `autoDispose FutureProvider.family` `.future` hangs on error; use `container.listen` + `Completer` pattern instead
- Notifier can't be constructed directly — test through `ProviderContainer` + `onboardingProvider.notifier`
- Duplicate override assertion added — avoid overriding the same provider twice in one container
