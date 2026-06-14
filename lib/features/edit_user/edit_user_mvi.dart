import '../../core/mvi.dart';
import '../../data/user_repository.dart';
import '../../models/user.dart';

// ---------------------------------------------------------------------------
// Intent
// ---------------------------------------------------------------------------
sealed class EditUserIntent extends MviIntent {}

class NameChanged extends EditUserIntent {
  final String value;
  NameChanged(this.value);
}

class EmailChanged extends EditUserIntent {
  final String value;
  EmailChanged(this.value);
}

class PhoneChanged extends EditUserIntent {
  final String value;
  PhoneChanged(this.value);
}

/// Fired when the user taps "Save".
class SaveUserTapped extends EditUserIntent {}

/// Fired when the user taps "Cancel" / closes the screen without saving.
class CancelEditTapped extends EditUserIntent {}

// ---------------------------------------------------------------------------
// State
// ---------------------------------------------------------------------------
class EditUserState extends MviState {
  final User original;
  final String name;
  final String email;
  final String phone;
  final bool isSaving;
  final String? error;

  const EditUserState({
    required this.original,
    required this.name,
    required this.email,
    required this.phone,
    this.isSaving = false,
    this.error,
  });

  factory EditUserState.fromUser(User user) => EditUserState(
        original: user,
        name: user.name,
        email: user.email,
        phone: user.phone,
      );

  bool get isValid => name.trim().isNotEmpty && email.contains('@');

  EditUserState copyWith({
    String? name,
    String? email,
    String? phone,
    bool? isSaving,
    String? error,
  }) {
    return EditUserState(
      original: original,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      isSaving: isSaving ?? this.isSaving,
      error: error,
    );
  }
}

// ---------------------------------------------------------------------------
// Effect
// ---------------------------------------------------------------------------
sealed class EditUserEffect extends MviEffect {}

/// Close this screen. [savedUser] is non-null on a successful save and
/// null when the user cancels — the caller (UserDetails) decides what to
/// do with each case.
class CloseEditUser extends EditUserEffect {
  final User? savedUser;
  CloseEditUser(this.savedUser);
}

/// Show an error message (e.g. via SnackBar).
class ShowEditUserError extends EditUserEffect {
  final String message;
  ShowEditUserError(this.message);
}

// ---------------------------------------------------------------------------
// ViewModel
// ---------------------------------------------------------------------------
class EditUserViewModel
    extends MviViewModel<EditUserIntent, EditUserState, EditUserEffect> {
  final UserRepository _repository;

  EditUserViewModel(this._repository, User user)
      : super(EditUserState.fromUser(user));

  @override
  void onIntent(EditUserIntent intent) {
    switch (intent) {
      case NameChanged(value: final value):
        emitState(state.copyWith(name: value));
      case EmailChanged(value: final value):
        emitState(state.copyWith(email: value));
      case PhoneChanged(value: final value):
        emitState(state.copyWith(phone: value));
      case SaveUserTapped():
        _save();
      case CancelEditTapped():
        emitEffect(CloseEditUser(null));
    }
  }

  Future<void> _save() async {
    if (!state.isValid) {
      emitEffect(ShowEditUserError('Please enter a valid name and email.'));
      return;
    }

    emitState(state.copyWith(isSaving: true, error: null));
    try {
      final updated = state.original.copyWith(
        name: state.name.trim(),
        email: state.email.trim(),
        phone: state.phone.trim(),
      );
      final saved = await _repository.updateUser(updated);
      emitState(state.copyWith(isSaving: false));
      emitEffect(CloseEditUser(saved));
    } catch (e) {
      emitState(state.copyWith(isSaving: false, error: e.toString()));
      emitEffect(ShowEditUserError(e.toString()));
    }
  }
}
