import 'dart:async';

import 'package:flutter/material.dart';

import '../../data/user_repository.dart';
import '../../models/user.dart';
import '../edit_user/edit_user_screen.dart';
import 'user_details_mvi.dart';

class UserDetailsScreen extends StatefulWidget {
  final UserRepository repository;
  final String userId;

  const UserDetailsScreen({
    super.key,
    required this.repository,
    required this.userId,
  });

  @override
  State<UserDetailsScreen> createState() => _UserDetailsScreenState();
}

class _UserDetailsScreenState extends State<UserDetailsScreen> {
  late final UserDetailsViewModel _viewModel;
  StreamSubscription<UserDetailsEffect>? _effectSubscription;

  @override
  void initState() {
    super.initState();
    _viewModel = UserDetailsViewModel(widget.repository, widget.userId);
    _effectSubscription = _viewModel.effects.listen(_handleEffect);
    _viewModel.onIntent(LoadUserDetails());
  }

  Future<void> _handleEffect(UserDetailsEffect effect) async {
    switch (effect) {
      case NavigateToEditUser(user: final user):
        final updated = await Navigator.of(context).push<User>(
          MaterialPageRoute(
            builder: (_) => EditUserScreen(
              repository: widget.repository,
              user: user,
            ),
          ),
        );
        if (updated != null) {
          _viewModel.applyUpdatedUser(updated);
        }
      case ShowUserDetailsError(message: final message):
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(message)));
    }
  }

  @override
  void dispose() {
    _effectSubscription?.cancel();
    _viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('User details'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            tooltip: 'Edit user',
            onPressed: () => _viewModel.onIntent(EditUserTapped()),
          ),
        ],
      ),
      body: ListenableBuilder(
        listenable: _viewModel,
        builder: (context, _) {
          final state = _viewModel.state;

          if (state.isLoading && state.user == null) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state.error != null && state.user == null) {
            return Center(child: Text('Error: ${state.error}'));
          }

          final user = state.user!;
          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: CircleAvatar(
                    radius: 40,
                    child: Text(
                      user.name.isNotEmpty ? user.name[0] : '?',
                      style: const TextStyle(fontSize: 32),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                _DetailRow(label: 'Name', value: user.name),
                _DetailRow(label: 'Email', value: user.email),
                _DetailRow(label: 'Phone', value: user.phone),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;

  const _DetailRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(child: Text(value.isEmpty ? '-' : value)),
        ],
      ),
    );
  }
}
