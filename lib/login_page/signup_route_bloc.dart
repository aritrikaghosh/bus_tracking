import 'package:flutter_bloc/flutter_bloc.dart';

enum SignUpRouteState { selected, loaded, notSelected, notLoaded }

abstract class SignUpRouteListEvent {}

class SignUpRouteIsSelected extends SignUpRouteListEvent {}

class SignUpRouteIsLoaded extends SignUpRouteListEvent {}

class SignUpRouteIsNotSelected extends SignUpRouteListEvent {}

class SignUpRouteIsNotLoaded extends SignUpRouteListEvent {}

class SignUpRoutesBloc extends Bloc<SignUpRouteListEvent, SignUpRouteState> {
  SignUpRoutesBloc() : super(SignUpRouteState.notLoaded) {
    on<SignUpRouteIsSelected>((event, emit) => emit(SignUpRouteState.selected));
    on<SignUpRouteIsLoaded>((event, emit) => emit(SignUpRouteState.loaded));
    on<SignUpRouteIsNotSelected>(
        (event, emit) => emit(SignUpRouteState.notSelected));
    on<SignUpRouteIsNotLoaded>(
        (event, emit) => emit(SignUpRouteState.notLoaded));
  }
}
