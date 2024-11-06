import 'package:flutter_bloc/flutter_bloc.dart';

enum PlannedRouteState { selected, loaded, notSelected, notLoaded }

abstract class PlannedRouteListEvent {}

class PlannedRouteIsSelected extends PlannedRouteListEvent {}

class PlannedRouteIsLoaded extends PlannedRouteListEvent {}

class PlannedRouteIsNotSelected extends PlannedRouteListEvent {}

class PlannedRouteIsNotLoaded extends PlannedRouteListEvent {}

class PlannedRoutesBloc extends Bloc<PlannedRouteListEvent, PlannedRouteState> {
  PlannedRoutesBloc() : super(PlannedRouteState.notLoaded) {
    on<PlannedRouteIsSelected>(
        (event, emit) => emit(PlannedRouteState.selected));
    on<PlannedRouteIsLoaded>((event, emit) => emit(PlannedRouteState.loaded));
    on<PlannedRouteIsNotSelected>(
        (event, emit) => emit(PlannedRouteState.notSelected));
    on<PlannedRouteIsNotLoaded>(
        (event, emit) => emit(PlannedRouteState.notLoaded));
  }
}
