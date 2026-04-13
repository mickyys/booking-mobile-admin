import 'package:equatable/equatable.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object> get props => [];
}

class LoginRequested extends AuthEvent {
  final String email;
  final String password;

  const LoginRequested({required this.email, required this.password});

  @override
  List<Object> get props => [email, password];
}

class SocialLoginRequested extends AuthEvent {
  final String connection;

  const SocialLoginRequested({required this.connection});

  @override
  List<Object> get props => [connection];
}

class LogoutRequested extends AuthEvent {}
