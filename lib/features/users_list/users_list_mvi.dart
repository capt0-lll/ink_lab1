import '../../core/mvi.dart';
import '../../data/user_repository.dart';
import '../../models/user.dart';

// ---------------------------------------------------------------------------
// Intent — every action the user can take on this screen
// ---------------------------------------------------------------------------
sealed class UsersListIntent extends MviIntent {}

/// Fired once when the screen first appears.
class LoadUsers extends UsersListIntent {}

/// Fired on pull-to-refresh.
class RefreshUsers extends UsersListIntent {}

/// Fired when the user taps a row to open UserDetails.
class UserTapped extends UsersListIntent {
  final String userId;
  UserTapped(this.userId);
}

// ---------------------------------------------------------------------------
// State — everything the View needs to render itself
// ---------------------------------------------------------------------------
class UsersListState extends MviState {
  final bool isLoading;
  final List<User> users;
  final String? error;

  const UsersListState({
    this.isLoading = false,
    this.users = const [],
    this.error,
  });

  UsersListState copyWith({
    bool? isLoading,
    List<User>? users,
    String? error,
  }) {
    return UsersListState(
      isLoading: isLoading ?? this.isLoading,
      users: users ?? this.users,
      error: error,
    );
  }
}

// ---------------------------------------------------------------------------
// Effect — one-off events that should not live in State
// ---------------------------------------------------------------------------
sealed class UsersListEffect extends MviEffect {}

/// Navigate to UserDetails for the given user id.
class NavigateToUserDetails extends UsersListEffect {
  final String userId;
  NavigateToUserDetails(this.userId);
}

/// Show an error message (e.g. via SnackBar).
class ShowUsersListError extends UsersListEffect {
  final String message;
  ShowUsersListError(this.message);
}

// ---------------------------------------------------------------------------
// ViewModel — reduces Intents into State (+ Effects)
// ---------------------------------------------------------------------------
class UsersListViewModel
    extends MviViewModel<UsersListIntent, UsersListState, UsersListEffect> {
  final UserRepository _repository;

  UsersListViewModel(this._repository) : super(const UsersListState());

  @override
  void onIntent(UsersListIntent intent) {
    switch (intent) {
      case LoadUsers():
        _loadUsers();
      case RefreshUsers():
        _loadUsers();
      case UserTapped(userId: final id):
        emitEffect(NavigateToUserDetails(id));
    }
  }

  Future<void> _loadUsers() async {
    emitState(state.copyWith(isLoading: true, error: null));
    try {
      final users = await _repository.getUsers();
      emitState(state.copyWith(isLoading: false, users: users));
    } catch (e) {
      emitState(state.copyWith(isLoading: false, error: e.toString()));
      emitEffect(ShowUsersListError(e.toString()));
    }
  }
}
