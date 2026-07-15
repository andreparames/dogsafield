# Dogs Afield — Architecture

## Tech Stack
- **Flutter/Dart** with Riverpod state management
- **Supabase** backend (Auth, PostgreSQL, Storage, Realtime)
- **Google Maps** (`google_maps_flutter`)
- **Drift** (SQLite) for offline cache
- **go_router** for navigation
- **slang** for i18n

## Directory Structure (lib/)
```text
lib/
  main.dart                    # Entry point, Supabase init, auth listener
  app.dart                     # MaterialApp widget
  routes.dart                  # Central GoRouter definition + redirects
  core/
    database/                  # Drift DB, local cache, connectivity
    services/                  # LocationService, location providers
    notifications/             # Local push notification scheduling
    theme/                     # AppTheme (light)
    utils/                     # Constants
    widgets/                   # Reusable widgets (loading_indicator)
  shared/models/               # UserProfile, DogEvent, Dog, ConnectionStatus, AttendanceStatus
  features/
    onboarding/                # Auth, profile/dog creation, photo upload
    field_map/                 # Main map screen, event markers, RSVP, filters
    hosting/                   # Create/edit events, location picker, manage attendees
    verification_loop/         # Roll call, mutual matches, packmate sync
    connections/               # Block/unblock, report
    messaging/                 # Conversations, direct messages
    account/                   # Profile, settings, suspend, upgrade
    info/                      # First-time field intro tour
  i18n/                        # Generated translations (slang)
```

Each feature follows: `data/` (repositories), `state/` (Riverpod providers), `presentation/` (screens/widgets), `routes.dart`

## Routing (go_router)
Central router in `lib/routes.dart` with redirect logic:
- Unauthenticated → `/onboarding/welcome`
- Suspended → `/account/suspended`
- Auth onboarding incomplete → progresses through onboarding steps
- Auth + hasn't seen intro → `/field/intro`

23 routes total across 8 feature modules.

## Key Providers (Riverpod)
- **Repository Providers** — `Provider<T>` wrapping Supabase client + cache
- **Data Providers** — `FutureProvider` / `StreamProvider` for async reads
- **Action Notifiers** — `Notifier<T>` with sealed Idle/Loading/Success/Error states
- **Filter/UI State** — `Notifier<bool>` for toggles (e.g., `rsvpFilterProvider`)

## Data Flow
1. Widgets watch Riverpod providers
2. Providers call repository methods
3. Repositories check `ConnectivityService` → online: Supabase, offline: `LocalCacheService` (Drift)
4. Supabase Realtime used for messaging streams

## Auth Flow
- OAuth only (Google/Apple) via Supabase
- Redirect: `io.supabase.dogsafield://login-callback`
- Auth state changes trigger `authRefreshNotifier` → GoRouter redirect
- Existing users skip onboarding via `onboardingAutoInitProvider`

## Location
- `geolocator` wrapped in `LocationService`
- `currentPositionProvider` feeds map centering
- Permission handling with retry/settings redirect

## Filters (Nearby / My Packs)
- `rsvpFilterProvider` — bool toggle (`false`=Nearby, `true`=My Packs)
- `discoveredEventsProvider` — filters `allEventsProvider` by blocked users, then optionally by RSVP IDs

## Verification Loop
Post-event: Roll Call (check who you met) → Mutual Match resolution → Packmate connection → DM enabled

## Patterns
- Feature-first organization
- Repository pattern (no direct Supabase calls from widgets)
- Offline-first with local cache fallback
- Sealed state classes for action notifiers
- i18n via `slang` (`context.t.*`)
