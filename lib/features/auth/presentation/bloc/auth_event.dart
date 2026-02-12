import 'package:equatable/equatable.dart';
import '../../data/models/login_request.dart';
import '../../data/models/register_request.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

class AuthCheckRequested extends AuthEvent {
  const AuthCheckRequested();
}

class AuthLoginRequested extends AuthEvent {
  final LoginRequest request;
  const AuthLoginRequested(this.request);

  @override
  List<Object?> get props => [request.email];
}

class AuthRegisterRequested extends AuthEvent {
  final RegisterRequest request;
  const AuthRegisterRequested(this.request);

  @override
  List<Object?> get props => [request.email];
}

class AuthLogoutRequested extends AuthEvent {
  const AuthLogoutRequested();
}
