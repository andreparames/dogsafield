# TODO

## First phase

### Core & Cross-cutting
- [x] **Geolocation service** — background/foreground location permission & tracking
- [x] **Supabase schema** — create tables (cities, profiles, dogs, events, attendance, connections, blocks)
- [x] **Auth integration** — wire real OAuth (Google/Apple) through Supabase
- [x] **Onboarding submission** — connect final "Complete Profile" button to backend API
- [x] **Environment config** — `.env` file for SUPABASE_URL, SUPABASE_PUB_KEY
- [x] **CI / tests** — GitHub Actions workflow, 44 unit/widget tests passing

### Field Map (`lib/features/field_map/`)
- [x] **Map view** — Google Maps integration with user location marker
- [ ] **Event discovery** — fetch/filter events by location, type, and date
- [ ] **Hub Parks** — designated parks shown during city launch periods
- [ ] **Gathering detail** — view host info, amenity tags, What to Bring checklist
- [ ] **Attendee profiles** — browse RSVP list, read icebreaker stories
- [ ] **RSVP flow** — "Join Pack" button with trial/founder evaluation against event location
- [ ] Screens: `MapHubScreen`, `GatheringDetailsScreen`

### Hosting (`lib/features/hosting/`)
- [ ] **Template selection** — Dog Picnic (stationary), Pack Walk (linear), Field Games (structured) [disabled]
- [ ] **Location & time picker** — select park/trail from map, assign date/time window
- [ ] **Pack capacity** — set max RSVPs to prevent overcrowding
- [ ] **What to Bring checklist** — quick-select items (long line leash, human lunch, etc.)
- [ ] **Publish to Field** — instant publication to map for local users within radius
- [ ] Screens: `TemplateSelectScreen`, `CreateEventFormScreen`

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
- [ ] Screens: `UpgradeScreen`, `FoundingPackBadge`, `TrialLimitSheet`

### Verification Loop (`lib/features/verification_loop/`)
- [ ] **Hardening** — anti-collusion checks, dispute process, no-show penalties (post-v1)

### Core & Cross-cutting
- [ ] **AI photo verification** — stub or integrate computer vision check for dual-subject photo