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

### User screen (`lib/features/user/`)
- [ ] **Avatar button** — circular user photo on the Field Map (top-left) as entry point
- [ ] **Profile screen** — displays user's name and their registered dog(s)
- [ ] **Suspend account** — hides the user everywhere (events, attendance, discoverability) without deleting data; must re-enable to use the app (no ghost usage)
- [ ] **Delete account** — fully removes all data, confirmation sent via email

### Info screens
- [ ] **Field intro screen** — first time accessing the Field, show an illustrated explainer of how it works
- [ ] **Host responsibility screen** — first time tapping "add new event", show tips about showing up and hosting etiquette

### Hosting (`lib/features/hosting/`)
- [x] **CreateEventScreen** — form with template (Dog Picnic/Pack Walk/Field Games), title, description, location, date/time picker, max attendees, what-to-bring checklist
- [x] **HostingRepository** — Supabase insert + fetch for events table
- [x] **Publish to Field** — submit event to Supabase with RLS (host_id = auth.uid())
- [x] **Location & time picker** — select park/trail from map, assign date/time window

### Verification Loop (`lib/features/verification_loop/`)
- [ ] **Post-event trigger** — push notification 2 hours after gathering start
- [ ] **Attendance roll call** — peer-driven check-off of dogs seen at the event
- [ ] **Cross-reference engine** — mutual confirmation or host fallback to authorize connections
- [ ] **Packmate unlock** — permanently enable DM channel upon verification
- [ ] Screens: `RollCallScreen`, `MutualMatchScreen`

### Connections (`lib/features/connections/`)
- [ ] **Tier 1 — Block** — cut DM, revoke Packmate, remove from each other's view
- [ ] **Tier 2 — Block & Hide** — hide hosted events, omit from attendee lists; notify blocker if blocked user joins same event
- [ ] **Tier 3 — Block, Hide & Report** — free-text report routed to Trust & Safety queue
- [ ] **Visibility filter queries** — consumed by field_map, hosting, verification_loop
- [ ] Screens: `BlockedUsersScreen`, `ReportDialog`

### Messaging (`lib/features/messaging/`)
- [ ] **Real-time chat** — DM streams (depends on connections/ for permission checks)
- [ ] **Packmate-gated** — only unlocked after Presence Verification Loop
- [ ] Screens: `ChatListScreen`, `DirectMessageScreen`


## Second phase

### Account (`lib/features/account/`)
- [ ] **Trial RSVP counter** — track and enforce the 3-free-RSVP lifetime trial limit
- [ ] **Subscription upgrade** — premium subscription gate when trial exhausted
- [ ] **Founding Pack eligibility** — detect 60-day launch-window registration
- [ ] **Founding Pack activity lock** — require 3 verified attendances within 60 days to unlock
- [ ] **Geographic waiver** — waive fees for Founding Pack members attending events in their founding city
- [x] Screens: `UpgradeScreen`, `FoundingPackBadge`, `TrialLimitSheet`

### Verification Loop (`lib/features/verification_loop/`)
- [ ] **Hardening** — anti-collusion checks, dispute process, no-show penalties (post-v1)

### Core & Cross-cutting
- [ ] **Hub Parks** — designated parks shown during city launch periods
- [ ] **AI photo verification** — stub or integrate computer vision check for dual-subject photo