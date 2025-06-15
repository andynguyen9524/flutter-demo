import 'package:equatable/equatable.dart';

abstract class LoginState extends Equatable {
  @override
  bool get stringify => true;

  @override
  List<Object?> get props => [];
}

class LoadingState extends LoginState {}

class LoginFaileState extends LoginState {}

class IsLoginState extends LoginState {}

class ErrorState extends LoginState {
  final String message;

  ErrorState({required this.message});
}
