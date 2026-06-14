import '../../core/mvi.dart';
import '../../data/user_repository.dart';
import '../../models/user.dart';

// ---------------------------------------------------------------------------
// Intent
// ---------------------------------------------------------------------------
sealed class UserDetailsIntent extends MviIntent {}

/// Fired once when the screen first appears.
class LoadUserDetails extends UserDetailsIntent {}

/// Fired when the user taps the "Edit" action to open EditUser.
class EditUserTapped extends UserDetailsIntent {}

// ---------------------------------------------------------------------------
// State
// ---------------------------------------------------------------------------
class UserDetailsState extends MviState {
  final bool isLoading;
  final User? user;
  final String? error;

  const UserDetailsState({
    this.isLoading = false,
    this.user,
    this.error,
  });

  UserDetailsState copyWith({
    bool? isLoading,
    User? user,
    String? error,
  }) {
    return UserDetailsState(
      isLoading: isLoading ?? this.isLoading,
      user: user ?? this.user,
      error: error,
    );
  }
}

// ---------------------------------------------------------------------------
// Effect
// ---------------------------------------------------------------------------
sealed class UserDetailsEffect extends MviEffect {}

/// Navigate to EditUser, passing the user currently shown.
class NavigateToEditUser extends UserDetailsEffect {
  final User user;
  NavigateToEditUser(this.user);
}

/// Show an error message (e.g. via SnackBar).
class ShowUserDetailsError extends UserDetailsEffect {
  final String message;
  ShowUserDetailsError(this.message);
}

// ---------------------------------------------------------------------------
// ViewModel
// ---------------------------------------------------------------------------
class UserDetailsViewModel extends MviViewModel<UserDetailsIntent,
    UserDetailsState, UserDetailsEffect> {
  final UserRepository _repository;
  final String userId;

  UserDetailsViewModel(this._repository, this.userId)
      : super(const UserDetailsState());

  @override
  void onIntent(UserDetailsIntent intent) {
    switch (intent) {
      case LoadUserDetails():
        _loadUser();
      case EditUserTapped():
        final user = state.user;
        if (user != null) {
          emitEffect(NavigateToEditUser(user));
        }
    }
  }

  /// Called by the View after EditUser returns a saved user, so the
  /// details screen reflects the change without an extra network call.
  void applyUpdatedUser(User user) {
    emitState(state.copyWith(user: user));
  }

  Future<void> _loadUser() async {
    emitState(state.copyWith(isLoading: true, error: null));
    try {
      final user = await _repository.getUserById(userId);
      emitState(state.copyWith(isLoading: false, user: user));
    } catch (e) {
      emitState(state.copyWith(isLoading: false, error: e.toString()));
      emitEffect(ShowUserDetailsError(e.toString()));
    }
  }
}
