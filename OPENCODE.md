# Dogs Afield — opencode session notes

## Project

Flutter app (Riverpod + go_router + Supabase). UI scaffold mostly done.

## Common commands

- `cd dogsafield` to enter project root
- `flutter pub get` after dependency changes
- `flutter run --dart-define=SUPABASE_URL=... --dart-define=SUPABASE_PUB_KEY=...`
- `flutter test` for tests

## Code conventions

- Feature-first folder layout under `lib/features/<name>/` with `data/`, `state/`, `presentation/`, `routes.dart`
- Use `context.push(...)` for forward navigation (preserves back button), NOT `context.go(...)`
- `Dog.id` must use `const Uuid().v4()` (from `package:uuid`), never timestamps
- Form validation: show `ScaffoldMessenger.of(context).showSnackBar(...)` instead of silent returns
- Riverpod providers: use `ref.watch(...)` inside providers for reactivity, not `ref.read(...)`
- Supabase OAuth: always pass `redirectTo: kAuthRedirectUrl`
- Handle `currentUser` null-safety — check and throw rather than force-unwrap
- Fail fast on missing env vars at startup (see `lib/main.dart`)
- SQL trigger functions: include `set search_path = ''` for security

## Key files

| File | Purpose |
|---|---|
| `lib/main.dart` | App entry, Supabase init, credential validation |
| `lib/app.dart` | MaterialApp.router shell |
| `lib/routes.dart` | Route aggregation |
| `lib/shared/models/` | Dog, Event, UserProfile data classes |
| `lib/features/onboarding/` | Auth, photo upload, profile form, icebreaker, safety boundaries |
| `lib/core/services/` | Location service + provider |
| `lib/core/theme/` | App theme |
| `supabase/migrations/` | DB schema and RLS policies |
| `TODO.md` | Feature roadmap |
| `Structure.md` | Folder layout reference |
| `Architecture.md` | Detailed user flows |
| `OPENCODE.md` | This file — session learnings |

## Git

- Branch: `initial-scaffold`
- Remote: `origin` (GitHub, SSH)
- SSH key at `~/.ssh/id_rsa` — use `$env:GIT_SSH_COMMAND = "ssh -i ..."`
- Never merge PRs — that's the user's job after review
