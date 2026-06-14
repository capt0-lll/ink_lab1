import 'dart:async';

import 'package:flutter/material.dart';

import '../../data/user_repository.dart';
import '../user_details/user_details_screen.dart';
import 'users_list_mvi.dart';

class UsersListScreen extends StatefulWidget {
  final UserRepository repository;

  const UsersListScreen({super.key, required this.repository});

  @override
  State<UsersListScreen> createState() => _UsersListScreenState();
}

class _UsersListScreenState extends State<UsersListScreen> {
  late final UsersListViewModel _viewModel;
  StreamSubscription<UsersListEffect>? _effectSubscription;

  @override
  void initState() {
    super.initState();
    _viewModel = UsersListViewModel(widget.repository);
    _effectSubscription = _viewModel.effects.listen(_handleEffect);
    _viewModel.onIntent(LoadUsers());
  }

  void _handleEffect(UsersListEffect effect) {
    switch (effect) {
      case NavigateToUserDetails(userId: final id):
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => UserDetailsScreen(
              repository: widget.repository,
              userId: id,
            ),
          ),
        );
      case ShowUsersListError(message: final message):
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
      appBar: AppBar(title: const Text('Users')),
      body: ListenableBuilder(
        listenable: _viewModel,
        builder: (context, _) {
          final state = _viewModel.state;

          if (state.isLoading && state.users.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state.error != null && state.users.isEmpty) {
            return Center(child: Text('Error: ${state.error}'));
          }

          return RefreshIndicator(
            onRefresh: () async => _viewModel.onIntent(RefreshUsers()),
            child: ListView.separated(
              itemCount: state.users.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final user = state.users[index];
                return ListTile(
                  leading: CircleAvatar(
                    child: Text(user.name.isNotEmpty ? user.name[0] : '?'),
                  ),
                  title: Text(user.name),
                  subtitle: Text(user.email),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => _viewModel.onIntent(UserTapped(user.id)),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
