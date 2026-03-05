import 'package:equatable/equatable.dart';

class UserEntity extends Equatable {
  final String id;
  final String username;
  final String password;
  final String fullName;

  const UserEntity({
    required this.id,
    required this.username,
    required this.password,
    required this.fullName,
  });

  @override
  List<Object?> get props => [id, username, password, fullName];
}
