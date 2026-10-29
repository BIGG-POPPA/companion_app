# WIZZ

A cross-platform virtual companion app built with Flutter and Firebase. Users adopt a pet cat whose needs change over time, keep a private mood journal, and review their care history. The pet's state persists in the cloud and continues to progress while the app is closed.

## Overview

WIZZ started as a way to practice building a complete, authenticated, cloud-backed mobile application rather than a single-screen demo. It covers account management, real-time data, background-aware state handling, and a custom UI layer, all in one codebase.

The pet has three stats: hunger, energy, and happiness. These decay with time and respond to user actions (feeding, playing, resting). The pet's mood, sprite, and the app's color theme are derived from those stats. A journal feature lets the user log how they feel each day, and the pet responds on the home screen with a matching message.

## Features

- Email and password authentication with sign-up, login, and password reset
- Auth-aware routing that switches between the login flow and the main app based on session state
- Pet care actions: feed, play, and put to sleep, with a timed sleep state that survives app restarts
- Stats dashboard showing hunger, energy, and happiness with live progress indicators
- Activity log of every action, with swipe-to-delete and a bulk clear option
- Daily mood journal with a four-level mood picker and a history of past check-ins
- Contextual pet messages on the home screen based on the latest journal mood for the current day
- Configurable difficulty ("neediness") that scales how quickly stats decay
- Pet renaming and full progress reset
- Dynamic theming: background and navigation colors change with the pet's current mood
- Reusable frosted glass UI components built on `BackdropFilter`

## Tech Stack

| Area | Technology |
| --- | --- |
| Framework | Flutter (Dart), Material 3 |
| Authentication | Firebase Authentication |
| Database | Cloud Firestore |
| State management | `ValueNotifier` / `ValueListenableBuilder` |
| Lifecycle handling | `WidgetsBindingObserver` |
| Date formatting | `intl` |

## Architecture

### Project structure

```
lib/
  main.dart               App entry point and AuthGate
  main_screen_page.dart   Bottom navigation shell (IndexedStack)
  logic_page.dart         Core pet logic, singleton state and Firestore access
  home_page.dart          Pet display and care actions
  stats_page.dart         Live stat cards
  logs_page.dart          Activity history
  user_log.dart           Mood journal
  setting_page.dart       Name, difficulty, reset, sign out
  login_page.dart.dart    Login screen
  signup_page.dart.dart   Registration screen
  glass_card.dart         Reusable frosted container
  glass_button.dart       Reusable frosted icon button
```

### State management

Pet state lives in a single `LogicPage` singleton that exposes each value (name, hunger, energy, happiness, mood, sleep status, decay factor) as a `ValueNotifier`. Screens subscribe with `ValueListenableBuilder`, so only the widgets that depend on a given value rebuild. This kept the dependency footprint small and avoided the boilerplate of a larger state management package for an app of this scope.

### Offline progression

The app does not run a background service. Instead, it uses lazy evaluation:

1. When the app is paused or becomes inactive, the current stats are written to Firestore along with a server-side `last_updated` timestamp.
2. When the app resumes, the elapsed time since `last_updated` is computed and applied to the stored stats as decay.
3. While the app is open, a one-minute periodic timer applies decay locally.

The same approach is used for sleep. A `sleep_until` timestamp is stored in Firestore when the pet is put to sleep. On resume, the app either restarts the countdown with the remaining time or applies the wake-up effects if the sleep period has already ended.

This gives the appearance of continuous simulation without battery cost or platform-specific background execution.

### Data model

```
pets/{uid}
  pet_name, hunger, energy, happiness,
  decay_factor, last_updated, sleep_until

users/{uid}/logs/{logId}
  activity, action, timestamp

users/{uid}/journal/{entryId}
  mood, log, created_at
```

Writes use `SetOptions(merge: true)` so partial updates never overwrite unrelated fields. UI state is updated immediately and persisted afterward, which keeps interactions responsive.

### UI components

`GlassCard` and `GlassButton` implement a frosted glass effect with `BackdropFilter`, a translucent fill, and a thin border. They are used across every screen to keep the visual language consistent and to avoid duplicated styling code.

## Getting Started

### Prerequisites

- Flutter SDK (stable channel)
- A Firebase project with Authentication (Email/Password) and Cloud Firestore enabled
- The FlutterFire CLI

### Setup

1. Clone the repository and install dependencies:

   ```bash
   git clone <repository-url>
   cd virtual_companion
   flutter pub get
   ```

2. Connect the project to your Firebase project:

   ```bash
   flutterfire configure
   ```

3. Add the cat sprites to `assets/` and declare them in `pubspec.yaml`:

   ```
   happy_cat.png
   hangry_cat.png
   sick_cat.png
   sleepy_cat.png
   sleeping_cat.png
   ```

4. Run the app:

   ```bash
   flutter run
   ```

### Suggested Firestore rules

Each user should only be able to read and write their own data:

```
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /pets/{uid} {
      allow read, write: if request.auth != null && request.auth.uid == uid;
    }
    match /users/{uid}/{document=**} {
      allow read, write: if request.auth != null && request.auth.uid == uid;
    }
  }
}
```

## What I Learned

- Structuring a Flutter app around a single source of truth and keeping UI widgets thin
- Handling the app lifecycle correctly so that state is saved and restored reliably
- Designing a Firestore schema around per-user access patterns and security rules
- Modeling time-based game mechanics without background processing
- Building reusable, composable widgets instead of repeating styling

## Known Limitations and Planned Improvements

- Decay is applied linearly; a non-linear model would feel more natural
- Resume-time sync and periodic local decay are handled separately, and could be unified
- Core logic is concentrated in one class and would benefit from being split into services and repositories
- No automated tests yet; unit tests for the decay and mood logic are the first priority
- Local notifications when the pet's needs are low
- Additional pet types and animations

## Author

Sohan S Dodamani
[github](https://github.com/BIGG-POPPA)
[linkedin](https://www.linkedin.com/in/sohan-dodamani/)