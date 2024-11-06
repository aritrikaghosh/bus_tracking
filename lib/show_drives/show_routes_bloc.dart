import 'package:flutter_bloc/flutter_bloc.dart';

enum RouteState { selected, loaded, notSelected, notLoaded }

abstract class RouteListEvent {}

class RouteIsSelected extends RouteListEvent {}

class RouteIsLoaded extends RouteListEvent {}

class RouteIsNotSelected extends RouteListEvent {}

class RouteIsNotLoaded extends RouteListEvent {}

class ShowRoutesBloc extends Bloc<RouteListEvent, RouteState> {
  ShowRoutesBloc() : super(RouteState.notLoaded) {
    on<RouteIsSelected>((event, emit) => emit(RouteState.selected));
    on<RouteIsLoaded>((event, emit) => emit(RouteState.loaded));
    on<RouteIsNotSelected>((event, emit) => emit(RouteState.notSelected));
    on<RouteIsNotLoaded>((event, emit) => emit(RouteState.notLoaded));
  }
}
