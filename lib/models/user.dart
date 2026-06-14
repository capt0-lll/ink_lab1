import 'package:flutter/foundation.dart';

/// The given "user" structure shared across all three screens.
@immutable
class User {
  final String id;
  final String name;
  final String email;
  final String phone;

  const User({
    required this.id,
    required this.name,
    required this.email,
    this.phone = '',
  });

  User copyWith({
    String? name,
    String? email,
    String? phone,
  }) {
    return User(
      id: id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is User &&
          other.id == id &&
          other.name == name &&
          other.email == email &&
          other.phone == phone);

  @override
  int get hashCode => Object.hash(id, name, email, phone);
}
