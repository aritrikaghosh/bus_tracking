import 'package:flutter_bloc/flutter_bloc.dart';

enum LoginState { loggedIn, notLoggedIn, error }

abstract class LoginEvent {}

class LoggedIn extends LoginEvent {}

class NotLoggedIn extends LoginEvent {}

class Error extends LoginEvent {}

class LoginBloc extends Bloc<LoginEvent, LoginState> {
  LoginBloc() : super(LoginState.notLoggedIn) {
    on<LoggedIn>((event, emit) => emit(LoginState.loggedIn));
    on<NotLoggedIn>((event, emit) => emit(LoginState.notLoggedIn));
    on<Error>((event, emit) => emit(LoginState.error));
  }
}
