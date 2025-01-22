import 'package:firenote_2/data/user.dart';

abstract class AuthenticationState {
  const AuthenticationState();
  List<Object> get props => [];
}

class AuthenticationInitialState extends AuthenticationState {}

class AuthenticationLoadingState extends AuthenticationState {}

class AuthenticationActionSuccessState extends AuthenticationState {
  final String successMessage;

  const AuthenticationActionSuccessState(this.successMessage);
  @override
  List<Object> get props => [successMessage];
}

class AuthenticationSuccessState extends AuthenticationState {
  final UserModel user;

  const AuthenticationSuccessState(this.user);
  @override
  List<Object> get props => [user];
}

class AuthenticationFailureState extends AuthenticationState {
  final String errorMessage;

  const AuthenticationFailureState(this.errorMessage);
  @override
  List<Object> get props => [errorMessage];
}
