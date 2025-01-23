abstract class AuthenticationEvent {
  const AuthenticationEvent();

  List<Object> get props => [];
}

class SignUpUser extends AuthenticationEvent {
  final String email;
  final String password;

  SignUpUser(this.email, this.password);

  @override
  List<Object> get props => [email, password];
}

class RecoverUserPassword extends AuthenticationEvent {
  final String email;

  RecoverUserPassword(this.email);

  @override
  List<Object> get props => [email];
}

class SignInUser extends AuthenticationEvent {
  final String email;
  final String password;

  SignInUser(this.email, this.password);

  @override
  List<Object> get props => [email, password];
}

class SignOutUser extends AuthenticationEvent {}

class CheckCurrentUser extends AuthenticationEvent {
  const CheckCurrentUser();
}