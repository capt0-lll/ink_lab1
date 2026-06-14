# MVI Users Demo (Flutter)

A minimal Flutter app demonstrating the **MVI (Model–View–Intent)** pattern
across three screens built around a single `User` model.

## Flow

```
UsersListScreen  --(tap a user)-->  UserDetailsScreen  --(tap edit)-->  EditUserScreen
                                            ^                                  |
                                            └---------(returns saved User)----┘
```

## MVI building blocks (`lib/core/mvi.dart`)

- **Intent** — every user action (`LoadUsers`, `UserTapped`, `SaveUserTapped`, ...).
- **State** — a single immutable object describing everything the screen
  needs to render (`UsersListState`, `UserDetailsState`, `EditUserState`).
- **Effect** — one-off events that aren't part of state: navigation,
  snackbars, etc. (`NavigateToUserDetails`, `CloseEditUser`, ...).
- **ViewModel** — receives Intents via `onIntent`, talks to `UserRepository`,
  and emits new `State` (via `emitState`) and/or `Effect`s (via `emitEffect`).
- **Screen (View)** — a `StatefulWidget` that:
  1. Rebuilds via `ListenableBuilder` whenever `state` changes.
  2. Subscribes to `effects` to perform navigation / show messages.
  3. Forwards all user interactions as `Intent`s — never mutates state directly.

## Project structure

```
lib/
  core/mvi.dart                  Base MviIntent / MviState / MviEffect / MviViewModel
  models/user.dart                Shared User model
  data/user_repository.dart        In-memory data source (swap for a real API)
  features/
    users_list/
      users_list_mvi.dart          Intent, State, Effect, ViewModel
      users_list_screen.dart       View
    user_details/
      user_details_mvi.dart
      user_details_screen.dart
    edit_user/
      edit_user_mvi.dart
      edit_user_screen.dart
  main.dart                        Wires UserRepository + initial route
```

## Screens

- **UsersList** — loads all users (`LoadUsers`), supports pull-to-refresh
  (`RefreshUsers`), and navigates to `UserDetails` on tap (`UserTapped` →
  `NavigateToUserDetails` effect).
- **UserDetails** — loads a single user (`LoadUserDetails`) and opens
  `EditUser` (`EditUserTapped` → `NavigateToEditUser` effect), passing the
  current `User`. When `EditUser` returns an updated `User`, the details
  screen calls `applyUpdatedUser` to refresh its state.
- **EditUser** — keeps editable `name` / `email` / `phone` in its `State`,
  validates on `SaveUserTapped`, persists via `UserRepository.updateUser`,
  and emits `CloseEditUser(savedUser)` (or `CloseEditUser(null)` on cancel)
  so the caller decides what to do with the result.

## Running

```bash
flutter pub get
flutter run
```
