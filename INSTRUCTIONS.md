# Dogs Afield — Session Instructions

## Workflow for feature implementation

### 1. Plan first
- Read the relevant files to understand the current state
- Read TODO.md to confirm the item exists and hasn't changed
- Present a plan to the user before writing any code

### 2. Branch and implement
- Branch from `master`: `git checkout master && git pull && git checkout -b feature-name`
- Use `feature/` prefix for features, `fix/` for bug fixes
- Follow existing code conventions:
  - Feature-first layout: `lib/features/<name>/data/`, `state/`, `presentation/`
  - Riverpod for state management
  - Supabase for backend
  - Material 3
- Keep files focused — one class/concern per file
- Do NOT add comments to code unless asked

### 3. Verify locally
```powershell
dart analyze lib/ test/
flutter test --no-pub
```
- Both must pass with zero issues before committing
- If tests need updating to match new behavior, update them

### 4. Commit and push
```powershell
git add -A
git commit -m "feature: concise description"
git push origin feature-name
```

### 5. Create PR
```powershell
gh pr create --title "Short title" --body "Bullet list of changes"
```

### 6. CodeRabbit loop
Wait **10 minutes** after pushing/commenting before checking.

```
1. Wait 10m
2. Check CodeRabbit review:
   - Fix only Major/Minor issues
   - Skip Trivial/Nitpick comments
3. Push fixes
4. Wait 10m
5. Comment on PR: "@coderabbitai are the issues fixed?"
   (DO NOT use "@coderabbitai review" — asking "are the issues fixed?" triggers a focused re-check)
6. Wait 10m
7. Read CodeRabbit's response
8. If issues remain → go to step 2
9. If clean → proceed
```

To check CodeRabbit's latest response:
```powershell
gh pr view <number> --comments --json "comments" --jq "[.comments[] | select(.author.login == \"coderabbitai\") | .body][-1]"
```

### 7. Merge or stop
- If user said to merge: `gh pr merge <number> --squash --subject "Title" --body "Body"`
- If user said "do NOT merge": stop and report

## Commit message style
- Prefix: `feature:`, `fix:`, `refactor:`, `test:`, `docs:`
- Imperative mood, no period
- Examples:
  - `feature: add RSVP button to gathering detail screen`
  - `fix: handle missing photoUrl in CircleAvatar fallback`
  - `refactor: parallelize _fetchAttendees profile/dog queries`

## Testing conventions
- Widget tests for screens and bottom sheets
- Provider tests for state logic
- Repository tests for data layer
- Use `Fake*` classes from `test/helpers/test_utils.dart` for dependency overrides
- Test file at: `test/features/<name>/<component>_test.dart`

## Key patterns to remember
- Do NOT add code comments unless asked
- Do NOT create README or doc files unless asked
- Do NOT commit unless explicitly told to
- Keep responses short — the output is displayed on a CLI