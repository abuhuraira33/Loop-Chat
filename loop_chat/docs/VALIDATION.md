# Validation

Verified with Flutter 3.35.7 and Dart 3.9.2 on Linux.

- `flutter analyze --no-pub`: no issues.
- `flutter test --no-pub --reporter expanded --dart-define=CAPTURE_PREVIEWS=true`: 9 tests passed.
- `flutter build web --no-pub --no-web-resources-cdn`: successful release build.
- Visually reviewed the generated welcome, chats, conversation and desktop screenshots.
- Confirmed the Dart runtime imports use only Flutter, Dart and this project.
- Confirmed Firebase service files, Firebase Gradle plugins and Socket.IO dependencies are absent.

The tests cover local messages, reply cancellation, unread counts, demo resets, search, navigation, profile edits, theme changes, compact phone layout and desktop navigation.

Android, iOS, Windows, Linux and macOS runner source is included. Native binaries were not compiled in this environment; they require their platform SDKs. The ZIP contains source and previews, rather than an APK or web build output.

## Previews

Actual Flutter widget captures are in `docs/screenshots/`:

- `welcome.png`
- `chats.png`
- `conversation.png`
- `profile-dark.png`
- `desktop-dark.png`

To refresh them, run:

```sh
flutter test test/preview_test.dart --dart-define=CAPTURE_PREVIEWS=true
```
