import '../models/user.dart';

/// Simple in-memory data source.
///
/// Swap this implementation for a real API/database client without
/// touching any ViewModel — they only depend on this interface's shape.
class UserRepository {
  final List<User> _users = [
    const User(
      id: '1',
      name: 'Alice Johnson',
      email: 'alice@example.com',
      phone: '+1 555 0101',
    ),
    const User(
      id: '2',
      name: 'Bob Smith',
      email: 'bob@example.com',
      phone: '+1 555 0102',
    ),
    const User(
      id: '3',
      name: 'Carla Diaz',
      email: 'carla@example.com',
      phone: '+1 555 0103',
    ),
    const User(
      id: '4',
      name: 'David Lee',
      email: 'david@example.com',
      phone: '+1 555 0104',
    ),
  ];

  Future<List<User>> getUsers() async {
    await Future.delayed(const Duration(milliseconds: 400));
    return List.unmodifiable(_users);
  }

  Future<User> getUserById(String id) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _users.firstWhere(
      (u) => u.id == id,
      orElse: () => throw Exception('User $id not found'),
    );
  }

  Future<User> updateUser(User user) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final index = _users.indexWhere((u) => u.id == user.id);
    if (index == -1) {
      throw Exception('User ${user.id} not found');
    }
    _users[index] = user;
    return user;
  }
}
