# TODO

## First phase

### Core & Cross-cutting
- [x] **Geolocation service** — background/foreground location permission & tracking
- [x] **Supabase schema** — create tables (cities, profiles, dogs, events, attendance, connections, blocks)
- [x] **Auth integration** — wire real OAuth (Google/Apple) through Supabase
- [x] **Onboarding submission** — connect final "Complete Profile" button to backend API
- [x] **Environment config** — `.env` file for SUPABASE_URL, SUPABASE_PUB_KEY
- [x] **CI / tests** — GitHub Actions workflow, 95 unit/widget tests passing
- [x] **Skip onboarding** — returning users with existing profiles skip onboarding and go to the map

### Field Map (`lib/features/field_map/`)
- [ ] **Multi-dog support** — `GatheringRepository._fetchDog` uses `.limit(1)` which silently drops dogs when a user has multiple; add `is_primary` flag to `dogs` table and query the primary dog
- [x] **Map view** — Google Maps integration with user location marker
- [ ] **Hide user location marker** — the red dot on current location is redundant, remove it
- [ ] **RSVP filter: local toggle, no re-fetch** — load all markers once, hide/show based on RSVP flag instead of re-querying Supabase
- [ ] **Marker color by RSVP status** — change marker tint depending on whether the user has RSVP'd
- [ ] **Bottom sheet: no scroll, all info visible** — all content and buttons must fit without scrolling; disable sheet scrolling entirely
- [ ] **Feedback button** — small chat-bubble icon in the app bar or as a non-conflicting widget (add-event FAB already occupies the FAB slot)
- [x] **Event discovery** — fetched nearby events + My RSVPs toggle, map markers colored by EventType, bottom sheet on tap, gathering detail stub screen

- [x] **Gathering detail** — view host info, amenity tags, What to Bring checklist, loading/error/retry states
- [x] **Attendee profiles** — browse RSVP list, read icebreaker stories
- [x] **RSVP flow** — "Join Pack" / "Cancel RSVP" buttons with trial/founder stubbed, SnackBar feedback on errors
- [x] **GatheringDetailsScreen** — full screen with event info, host card, amenities, what-to-bring, attendance count, RSVP actions

### Account screen (`lib/features/account/`)
- [x] **Avatar button** — circular user photo on the Field Map (top-left) as entry point, routes to `/account`
- [x] **Profile screen** — displays user's name, dog info, trial counter, Founding Pack badge
- [x] **Trial limit enforcement** — 3-free-RSVP lifetime limit with sheet
- [x] **Founding Pack eligibility** — detect 60-day launch-window registration
- [x] **Upgrade screen** — premium subscription gate when trial exhausted
- [x] **Suspend account** — hides the user everywhere (events, attendance, discoverability) without deleting data; must re-enable to use the app (no ghost usage)
- [x] **Delete account** — fully removes all data via `delete_my_account()` RPC; confirmation dialog with "type DELETE" gate

### Info screens
- [x] **Field intro screen** — first time accessing the Field, show an illustrated explainer of how it works; wire redirect in auth flow
- [x] **Host responsibility screen** — wire to trigger on first "+" tap via `has_seen_host_intro` profile flag

### Hosting (`lib/features/hosting/`)
- [x] **CreateEventScreen** — form with event type, title, description, location, date/time, max attendees, what-to-bring
- [x] **HostingRepository** — `createEvent()`, `fetchMyEvents()`
- [x] **Publish to Field** — submit event to Supabase with RLS (host_id = auth.uid())
- [x] **Location & time picker** — select park/trail from map, assign date/time window
- [x] **Host responsibility screen** — first-time host education before create flow
- [x] **My Events dashboard** — list host's events with attendee counts, edit/delete actions
- [x] **Edit Event** — re-use create screen in edit mode with pre-populated fields
- [ ] **RSVP notifications on edit** — push notification to RSVP'd attendees when host edits event
- [x] **Cancel / Delete Event** — confirmation dialog, soft-delete via `is_cancelled` column
- [x] **Attendee management** — RSVP list with names/dogs, host can remove attendees
- [x] **Hosting state notifiers** — sealed-class notifiers for create, edit, delete
- [x] **Tests** — widget tests for new screens, provider tests for notifiers

### Verification Loop (`lib/features/verification_loop/`)
- [x] **Post-event trigger** — local notification "Who'd you meet?" scheduled 2h after event start; check-in section shown on past-event detail screen
- [x] **Check-in/confirmation** — "Who'd you meet?" screen to check off people you met at the event
- [x] **Cross-reference engine** — mutual confirmation matching; sets `are_packmates = true` on mutual meet
- [x] **Packmate unlock** — `are_packmates` column set to `true` in `connections` table upon mutual meet
- [x] Screens: "Who'd you meet?", "Who you met"

### Connections (`lib/features/connections/`)
- [x] **Tier 1 — Block** — data layer, state notifier, UI via attendee card overflow menu
- [x] **Tier 2 — Block & Hide** — data layer, state notifier, UI via attendee card overflow menu
- [x] **Tier 3 — Block, Hide & Report** — data layer, state notifier, ReportDialog wired into flow
- [x] **Visibility filter queries** — `blockedUserIdsProvider`/`blockerIdsProvider` consumed by field_map (events) and gathering (attendees)
- [x] Screens: `BlockedUsersScreen`, `ReportDialog`
- [ ] **Messaging integration** — cut DM on block (depends on messaging feature)
- [ ] **Packmate revocation enforcement** — downstream effects beyond DB write
- [ ] **Blocker notification** — alert host when blocked user RSVPs to their event
- [ ] **Trust & Safety queue** — admin routing for Tier 3 reports

### Messaging (`lib/features/messaging/`)
- [ ] **Real-time chat** — DM streams (depends on connections/ for permission checks)
- [ ] **Packmate-gated** — only unlocked after Presence Verification Loop
- [ ] Screens: `ChatListScreen`, `DirectMessageScreen`


### Offline Read-Only Support

**Phase 1 — Add Drift**
- [x] Add dependencies: `drift`, `sqlite_flutter_libs`, `connectivity_plus`, `path_provider`, `path`
- [x] Create `lib/core/database/` with Drift tables mirroring Supabase: `events`, `profiles`, `dogs`, `attendance`
- [x] Create `AppDatabase` class (Drift `_$AppDatabase`)

**Phase 2 — Cache layer**
- [x] Create `LocalCacheService` with upsert methods for each table and read methods matching repository queries (nearby events, gathering detail, RSVP IDs)
- [x] Store last-sync timestamp per table in SharedPreferences
- [x] Create connectivity wrapper (`connectivity_plus` stream)

**Phase 3 — Wire into repositories**
- [x] Inject `LocalCacheService` + connectivity into `FieldMapRepository`, `GatheringRepository`, `RsvpRepository`
- [x] Each read method: online → fetch from Supabase + upsert cache; offline → read from Drift
- [x] Add Riverpod providers: `localDatabaseProvider`, `localCacheServiceProvider`, `connectivityProvider`
- [x] **Unit tests** — `LocalCacheService` upsert/read/miss methods with in-memory Drift; connectivity wrapper emits correct states
- [ ] **Widget tests** — screens render cached data when offline (mock `LocalCacheService` + connectivity)
- [ ] **Integration/end-to-end** — simulate offline: repositories return cached data, no Supabase calls fire
- [x] Verify existing tests still pass after repository refactors

**Phase 4 — Offline profile persistence**
- [x] Cache user profile and dog locally after onboarding creation
- [x] Fall back to local cache when fetching existing profile while offline

### Privacy
- [ ] **Audit API data exposure** — review every table/endpoint the app queries; ensure only necessary fields are returned (e.g. profiles should not expose email, is_suspended, intro flags to other users)
- [ ] **Server-enforced profile field minimization** — use column-level privileges or security barrier views so the Data API cannot return sensitive profile columns (email, is_verified, trial_rsvps_used, is_founding_pack, is_suspended, intro flags, treat_policy) to other users even from a malicious client. Only the row owner should be able to read their own sensitive fields
- [ ] **Blocked user data isolation** — confirm blocked users cannot see each other's profiles/events/attendance beyond block-tier rules

### Polish
- [ ] **Map edge-to-edge inset** — Field map should not overlap Android status bar (battery, clock, etc.)
- [ ] **Marker flicker on filter toggle** — markers should not flash/re-render when switching between Nearby and My RSVPs
- [ ] **Trial RSVPs info card** — replace repeated data with a short paragraph explaining the trial period
- [ ] **Move "add event" FAB** — the add-event button sits on top of the map's zoom controls; reposition it so it doesn't overlap

## Second phase

### Account (`lib/features/account/`)
- [ ] **Founding Pack activity lock** — require 3 verified attendances within 60 days to unlock
- [ ] **Geographic waiver** — waive fees for Founding Pack members attending events in their founding city

### Verification Loop (`lib/features/verification_loop/`)
- [ ] **Hardening** — anti-collusion checks, dispute process, no-show penalties (post-v1)

### Core & Cross-cutting
- [ ] **Hub Parks** — designated parks shown during city launch periods
- [ ] **AI photo verification** — stub or integrate computer vision check for dual-subject photo