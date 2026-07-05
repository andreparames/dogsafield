lib/
│
├── main.dart                      # App entry point & initialization
├── app.dart                       # MaterialApp shell, theme, top-level auth gate
├── routes.dart                    # Aggregates each feature's routes into one route table
│
├── core/                          # Shared utilities used across multiple features
│   ├── theme/                     # Global colors, fonts, and button styles
│   ├── utils/                     # Date formatters, validators, and constants
│   └── widgets/                   # Reusable UI elements (custom buttons, loading spinners)
│
├── shared/                        # Cross-feature domain layer
│   └── models/                    # Event, Dog, UserProfile, ConnectionStatus — entities
│                                   # referenced by 3+ features, kept out of any one feature
│                                   # to avoid drift/duplication
│
└── features/                      # Self-contained modules mapping to your user flows
    │
    ├── onboarding/                # Flow 1: Auth, Photo Upload, AI Check, Dog Profile
    │   ├── data/                  # API calls (Supabase/Firebase auth, AWS Rekognition)
    │   ├── state/                 # Onboarding step tracker (renamed from providers/ —
    │   │                          # avoids assuming Provider pkg vs Riverpod/Bloc)
    │   ├── presentation/          # WelcomeScreen, PhotoUploadScreen, ProfileFormScreen
    │   └── routes.dart
    │
    ├── account/                   # NEW — Flow 2: trial RSVP count, subscription upgrade,
    │   │                          # Founding Pack eligibility & geographic waiver logic
    │   ├── data/                  # Billing provider calls, founding-city boundary checks
    │   ├── state/                 # Trial count, subscription status, founder status
    │   ├── presentation/          # UpgradeScreen, FoundingPackBadge, TrialLimitSheet
    │   └── routes.dart
    │
    ├── field_map/                 # Flow 3: Map View, Hub Parks, Event Discovery
    │   ├── data/                  # Fetching local events based on coordinates
    │   ├── state/                 # Map marker state, search filters
    │   ├── presentation/          # MapHubScreen, GatheringDetailsScreen
    │   └── routes.dart
    │
    ├── hosting/                   # Flow 4: Event Templates, Capacity, Rules Creation
    │   ├── data/                  # Creating/publishing events to backend database
    │   ├── state/
    │   ├── presentation/          # TemplateSelectScreen, CreateEventFormScreen
    │   └── routes.dart
    │
    ├── verification_loop/         # Flow 5: Post-Event Notification, Peer Attendance Check
    │   ├── data/                  # Submitting peer attendance cross-references
    │   ├── state/
    │   ├── presentation/          # RollCallScreen, MutualMatchScreen
    │   └── routes.dart
    │
    ├── connections/               # NEW — owns Packmate status AND block state (Sec. 5 & 6)
    │   ├── data/                  # Packmate unlock mutations, block/unblock mutations,
    │   │                          # visibility-filter queries other features call into
    │   ├── state/                 # Current user's block list, packmate list
    │   ├── presentation/          # BlockedUsersScreen, ReportDialog
    │   └── routes.dart
    │                              # field_map, hosting, and verification_loop all depend
    │                              # on connections/ to filter what Bob can see —
    │                              # instead of that logic living inside messaging/
    │
    └── messaging/                 # Flow 6: Packmates Chat UI
        ├── data/                  # Real-time chat streams (depends on connections/
        │                          # for permission checks, not its own block logic)
        ├── state/
        ├── presentation/          # ChatListScreen, DirectMessageScreen
        └── routes.dart