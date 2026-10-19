# Loop Chat

A small Flutter chat UI, adapted from Ibad's Chat_Application project. It opens immediately without sign-in, accounts, cloud setup, or a server.

## Run

Install Flutter **3.35.7 or newer** with Dart **3.9.2 or newer**, then open this folder in Android Studio or VS Code.

```sh
flutter pub get
flutter run
```

For a browser preview:

```sh
flutter run -d chrome
```

For a release Android APK (requires the Android SDK):

```sh
flutter build apk --release
```

The APK appears at `build/app/outputs/flutter-apk/app-release.apk`. Release builds currently use Flutter's debug signing configuration; configure your own signing key before store distribution.

## What's included

- Loop Chat name, teal/mint theme and infinity app icon.
- Animated welcome screen, page transitions and message entrances.
- Chat list with search, unread and favorite filters.
- People directory with search and favorite toggles.
- Conversation screen with local message composition and optional simulated replies.
- Contact details and clear-conversation action.
- Editable name/about, light/dark appearance and demo reset.
- Mobile bottom navigation and desktop navigation rail.
- Reduced-motion support for entrance and route animations.
- Android, iOS, web, Windows, Linux and macOS runner source.

All names and messages are sample data. “Online,” typing and reply behavior are demonstrations. Messages, profiles, favorites and preferences exist **only in memory** and reset when the app fully restarts. There are no real calls, uploads, notifications or user accounts.

## Simple structure

```text
lib/
  main.dart                    Entry point
  app.dart                     App and theme selection
  theme.dart                   Shared light/dark styles
  demo_store.dart              Local sample data and session state
  screens/
    welcome_screen.dart
    home_screen.dart           Chats and people
    chat_screen.dart
    settings_screen.dart       Profile and preferences
  widgets/
    shared.dart                Avatars, logo and transitions
```

Flutter SDK widgets and ChangeNotifier handle the UI and state; there are **no third-party runtime packages**. Firebase, Firestore, authentication, storage, image picking, Socket.IO and platform service configuration have been removed.

## Verify

```sh
flutter analyze
flutter test
```

Tests cover local sends, reply cancellation, unread state, resets, navigation, search, profile editing, theme changes and compact/desktop layouts.

## Original source

Adapted from https://github.com/ibad-r/Chat_Application at commit `663f03edf29e83bc455da72453a72cdf293bca15`.

See [validation notes](docs/VALIDATION.md) and [screen previews](docs/screenshots/) for the checks completed on this version. Native platform builds require their corresponding SDKs; no APK is bundled.
