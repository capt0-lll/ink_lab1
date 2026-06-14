import 'dart:async';

import 'package:flutter/foundation.dart';

/// Marker interface for all user intents (actions) dispatched from a View.
abstract class MviIntent {}

/// Marker interface for the immutable UI state rendered by a View.
abstract class MviState {
  const MviState();
}

/// Marker interface for one-off side effects (navigation, snackbars, etc.)
/// that should never become part of the persisted state.
abstract class MviEffect {
  const MviEffect();
}

/// Base class for an MVI ViewModel.
///
/// - [I] intents accepted from the View.
/// - [S] state rendered by the View.
/// - [E] one-off effects emitted to the View.
///
/// The unidirectional flow is:
///   View --(Intent)--> ViewModel --(State)--> View
///                       ViewModel --(Effect)--> View
abstract class MviViewModel<I extends MviIntent, S extends MviState,
    E extends MviEffect> extends ChangeNotifier {
  MviViewModel(this._state);

  S _state;

  /// The current immutable state. Widgets read from here.
  S get state => _state;

  final StreamController<E> _effectController =
      StreamController<E>.broadcast();

  /// One-off effects (navigation, dialogs, snackbars...).
  Stream<E> get effects => _effectController.stream;

  /// Entry point called by the View whenever the user performs an action.
  void onIntent(I intent);

  /// Replaces the current state and notifies listeners.
  void emitState(S newState) {
    _state = newState;
    notifyListeners();
  }

  /// Sends a one-off effect to the View.
  void emitEffect(E effect) {
    if (!_effectController.isClosed) {
      _effectController.add(effect);
    }
  }

  @override
  void dispose() {
    _effectController.close();
    super.dispose();
  }
}
