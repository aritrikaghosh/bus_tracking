import 'package:flutter_bloc/flutter_bloc.dart';

enum DriverRouteState { selected, loaded, notSelected, notLoaded }

abstract class DriverRouteListEvent {}

class DriverRouteIsSelected extends DriverRouteListEvent {}

class DriverRouteIsLoaded extends DriverRouteListEvent {}

class DriverRouteIsNotSelected extends DriverRouteListEvent {}

class DriverRouteIsNotLoaded extends DriverRouteListEvent {}

class DriverRoutesBloc extends Bloc<DriverRouteListEvent, DriverRouteState> {
  DriverRoutesBloc() : super(DriverRouteState.notLoaded) {
    on<DriverRouteIsSelected>((event, emit) => emit(DriverRouteState.selected));
    on<DriverRouteIsLoaded>((event, emit) => emit(DriverRouteState.loaded));
    on<DriverRouteIsNotSelected>(
        (event, emit) => emit(DriverRouteState.notSelected));
    on<DriverRouteIsNotLoaded>(
        (event, emit) => emit(DriverRouteState.notLoaded));
  }
}
