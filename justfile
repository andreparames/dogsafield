default: test

[windows]
set shell := ["powershell.exe", "-NoLogo", "-Command"]

# Run tests
test:
  flutter test

# Run static analysis
analyze:
  flutter analyze

# Build debug APK
build-apk:
  flutter build apk --debug --target-platform android-arm,android-arm64,android-x64 --dart-define-from-file=.env
