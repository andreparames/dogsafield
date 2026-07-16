# AGENTS.md — Project context for AI coding sessions

## Shell
- **OS**: Windows — use PowerShell (NOT bash)
- **No `2>&1`** — PowerShell syntax differs; just let the tool capture output naturally

## Supabase
- **Project ref**: `noxyxxzetsrtkvrgpheq`
- **Auth**: Uses Management API (`POST /database/query`) — NOT direct DB password
- **Access token**: read from `C:\Users\andre\.supabase\access_token`
  - Also stored in Windows Credential Manager under `Supabase CLI:supabase`
  - Also set as GitHub secret `SUPABASE_ACCESS_TOKEN`
- **GitHub secret `SUPABASE_PROJECT_ID`**: `noxyxxzetsrtkvrgpheq`
- **CI**: `.github/workflows/supabase-migrations.yml` runs on push to `main`/`master`
  - Steps: `supabase link --project-ref` then `supabase db push --linked`
  - Both steps use `SUPABASE_ACCESS_TOKEN` at job-level env

## GitHub
- **Remote**: `andreparames/dogsafield`
- **Default branch**: `master` (NOT `main`)
- **Branch protection**: master requires PRs (can be bypassed with admin)

## Repo
- Flutter/Dart project with Riverpod state management
- Supabase backend with PostgreSQL
- Migrations in `supabase/migrations/`
- Full architecture docs: [Architecture.md](Architecture.md)

## Play Store / fastlane
- **Ruby** installed via winget (`ruby`), `fastlane` via `gem install fastlane`
- **Service account key**: `dogsafield-play-console-key.json` (gitignored by `dogsafield-*.json`)
- **Service account perms needed**: `CAN_VIEW_NON_FINANCIAL_DATA`, `CAN_MANAGE_PUBLIC_LISTING`, `CAN_MANAGE_TRACK_APKS`
- **Metadata lives at**: `metadata/android/en-US/` (title.txt, short_description.txt, full_description.txt, images/icon/icon.png)
- **Commands**:
  - Metadata-only upload: `fastlane supply --metadata-path metadata/android --json-key dogsafield-play-console-key.json --package-name com.spectrumveil.dogsafield --track internal --skip-upload-aab --skip-upload-apk --skip-upload-changelogs`
  - Full release (metadata + AAB): `fastlane supply --metadata-path metadata/android --json-key dogsafield-play-console-key.json --package-name com.spectrumveil.dogsafield --track internal --aab build/app/outputs/bundle/release/app-release.aab`
  - Before running, set: `$env:LANG = "en_US.UTF-8"; $env:LC_ALL = "en_US.UTF-8"; $env:Path = [Environment]::GetEnvironmentVariable("Path", "Machine") + ";" + [Environment]::GetEnvironmentVariable("Path", "User");`

## Credentials & Secrets (GitHub)
| Secret | Value |
|---|---|
| `GOOGLE_MAPS_API_KEY` | Set |
| `SUPABASE_ACCESS_TOKEN` | (read from `C:\Users\andre\.supabase\access_token`) |
| `SUPABASE_PROJECT_ID` | noxyxxzetsrtkvrgpheq |
