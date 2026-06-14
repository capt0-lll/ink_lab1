import 'package:flutter/material.dart';

import 'data/user_repository.dart';
import 'features/users_list/users_list_screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  final UserRepository repository = UserRepository();

  MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MVI Users Demo',
      theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.indigo),
      home: UsersListScreen(repository: repository),
    );
  }
}
