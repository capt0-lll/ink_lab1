import 'dart:async';

import 'package:flutter/material.dart';

import '../../data/user_repository.dart';
import '../../models/user.dart';
import 'edit_user_mvi.dart';

class EditUserScreen extends StatefulWidget {
  final UserRepository repository;
  final User user;

  const EditUserScreen({
    super.key,
    required this.repository,
    required this.user,
  });

  @override
  State<EditUserScreen> createState() => _EditUserScreenState();
}

class _EditUserScreenState extends State<EditUserScreen> {
  late final EditUserViewModel _viewModel;
  late final TextEditingController _nameController;
  late final TextEditingController _emailController;
  late final TextEditingController _phoneController;
  StreamSubscription<EditUserEffect>? _effectSubscription;

  @override
  void initState() {
    super.initState();
    _viewModel = EditUserViewModel(widget.repository, widget.user);
    _nameController = TextEditingController(text: widget.user.name);
    _emailController = TextEditingController(text: widget.user.email);
    _phoneController = TextEditingController(text: widget.user.phone);
    _effectSubscription = _viewModel.effects.listen(_handleEffect);
  }

  void _handleEffect(EditUserEffect effect) {
    switch (effect) {
      case CloseEditUser(savedUser: final savedUser):
        // Returns the saved user (or null if cancelled) to UserDetails.
        Navigator.of(context).pop(savedUser);
      case ShowEditUserError(message: final message):
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(message)));
    }
  }

  @override
  void dispose() {
    _effectSubscription?.cancel();
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit user'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => _viewModel.onIntent(CancelEditTapped()),
        ),
      ),
      body: ListenableBuilder(
        listenable: _viewModel,
        builder: (context, _) {
          final state = _viewModel.state;
          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextField(
                  controller: _nameController,
                  decoration: const InputDecoration(labelText: 'Name'),
                  onChanged: (value) =>
                      _viewModel.onIntent(NameChanged(value)),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _emailController,
                  decoration: const InputDecoration(labelText: 'Email'),
                  keyboardType: TextInputType.emailAddress,
                  onChanged: (value) =>
                      _viewModel.onIntent(EmailChanged(value)),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _phoneController,
                  decoration: const InputDecoration(labelText: 'Phone'),
                  keyboardType: TextInputType.phone,
                  onChanged: (value) =>
                      _viewModel.onIntent(PhoneChanged(value)),
                ),
                const SizedBox(height: 24),
                if (state.error != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Text(
                      state.error!,
                      style: const TextStyle(color: Colors.red),
                    ),
                  ),
                FilledButton(
                  onPressed: state.isSaving
                      ? null
                      : () => _viewModel.onIntent(SaveUserTapped()),
                  child: state.isSaving
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Save'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
