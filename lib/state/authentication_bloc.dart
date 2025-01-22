import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firenote_2/auth_service.dart';
import 'package:firenote_2/state/authentication_event.dart';
import 'package:firenote_2/state/authentication_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logging/logging.dart';
import 'dart:async';

import '../data/user.dart';

class AuthenticationBloc extends Bloc<AuthenticationEvent, AuthenticationState> {
  final AuthService authService = AuthService();
  final _logger = Logger('AuthenticationBloc');
  static const _timeoutDuration = Duration(seconds: 10);

  AuthenticationBloc() : super(AuthenticationInitialState()) {
    on<AuthenticationEvent>((event, emit) {});
    on<SignUpUser>(_onUserSignUp);
    on<SignInUser>(_onUserSignIn);
    on<SignOutUser>(_onSignOut);
    on<RecoverUserPassword>(_onPasswordRecovery);
  }

  Future<void> _onUserSignUp(
    SignUpUser event,
    Emitter<AuthenticationState> emit,
  ) async {
    emit(AuthenticationLoadingState());
    try {
      final UserModel? user = await _withTimeout(
        authService.signUpUser(event.email, event.password)
      );
      if (user != null) {
        emit(AuthenticationSuccessState(user));
      } else {
        emit(const AuthenticationFailureState('Create user failed'));
      }
    } on FirebaseAuthException catch (e) {
      _logger.warning('Firebase auth error during signup', e);
      emit(AuthenticationFailureState(_handleAuthError(e)));
    } on TimeoutException {
      _logger.severe('Signup operation timed out');
      emit(const AuthenticationFailureState('Operation timed out. Please try again.'));
    } catch (e) {
      _logger.severe('Unexpected error during signup', e);
      emit(AuthenticationFailureState(_handleGenericError(e)));
    }
  }

  Future<void> _onUserSignIn(
    SignInUser event,
    Emitter<AuthenticationState> emit,
  ) async {
    emit(AuthenticationLoadingState());
    try {
      final UserModel? user = await _withTimeout(
        authService.signInUser(event.email, event.password)
      );
      if (user != null) {
        emit(AuthenticationSuccessState(user));
      } else {
        emit(const AuthenticationFailureState('Sign in failed'));
      }
    } on FirebaseAuthException catch (e) {
      _logger.warning('Firebase auth error during signin', e);
      emit(AuthenticationFailureState(_handleAuthError(e)));
    } on TimeoutException {
      _logger.severe('Signin operation timed out');
      emit(const AuthenticationFailureState('Operation timed out. Please try again.'));
    } catch (e) {
      _logger.severe('Unexpected error during signin', e);
      emit(AuthenticationFailureState(_handleGenericError(e)));
    }
  }

  Future<void> _onSignOut(
    SignOutUser event, 
    Emitter<AuthenticationState> emit
  ) async {
    emit(AuthenticationLoadingState());
    try {
      await _withTimeout(authService.signOutUser());
      emit(const AuthenticationActionSuccessState("Sign out successful"));
    } on FirebaseAuthException catch (e) {
      _logger.warning('Firebase auth error during signout', e);
      emit(AuthenticationFailureState(_handleAuthError(e)));
    } on TimeoutException {
      _logger.severe('Signout operation timed out');
      emit(const AuthenticationFailureState('Operation timed out. Please try again.'));
    } catch (e) {
      _logger.severe('Unexpected error during signout', e);
      emit(AuthenticationFailureState(_handleGenericError(e)));
    }
  }

  Future<void> _onPasswordRecovery(
    RecoverUserPassword event,
    Emitter<AuthenticationState> emit
  ) async {
    emit(AuthenticationLoadingState());
    try {
      await _withTimeout(authService.recoverPassword(event.email));
      emit(const AuthenticationActionSuccessState("Recovery email sent"));
    } on FirebaseAuthException catch (e) {
      _logger.warning('Firebase auth error during password recovery', e);
      emit(AuthenticationFailureState(_handleAuthError(e)));
    } on TimeoutException {
      _logger.severe('Password recovery operation timed out');
      emit(const AuthenticationFailureState('Operation timed out. Please try again.'));
    } catch (e) {
      _logger.severe('Unexpected error during password recovery', e);
      emit(AuthenticationFailureState(_handleGenericError(e)));
    }
  }

  //timeout Wrapper
  Future<T> _withTimeout<T>(Future<T> future) {
    return future.timeout(
      _timeoutDuration,
      onTimeout: () => throw TimeoutException('Operation timed out'),
    );
  }

  String _handleGenericError(dynamic error) {
    if (error is SocketException || error is HttpException) {
      return 'Network error occurred. Please check your connection.';
    } else if (error is FormatException) {
      return 'Invalid data format. Please try again.';
    } else {
      return 'An unexpected error occurred. Please try again later.';
    }
  }
}

String _handleAuthError(FirebaseAuthException e) {
  switch (e.code) {
    case 'user-not-found':
      return 'No user found with this email.';
    case 'wrong-password':
      return 'Wrong password provided.';
    case 'email-already-in-use':
      return 'An account already exists with this email.';
    case 'invalid-email':
      return 'Please provide a valid email address.';
    case 'weak-password':
      return 'The password provided is too weak.';
    case 'operation-not-allowed':
      return 'Email/password accounts are not enabled.';
    case 'network-request-failed':
      return 'Network error occurred. Please check your internet connection.';
    case 'too-many-requests':
      return 'Too many attempts. Please try again later.';
    case 'user-disabled':
      return 'This account has been disabled.';
    default:
      return 'An authentication error occurred. Please try again.';
  }
}