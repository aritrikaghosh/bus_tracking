import 'package:flutter_bloc/flutter_bloc.dart';

enum DestinationRouteState { selected, loaded, notSelected, notLoaded }

abstract class DestinationRouteListEvent {}

class DestinationRouteIsSelected extends DestinationRouteListEvent {}

class DestinationRouteIsLoaded extends DestinationRouteListEvent {}

class DestinationRouteIsNotSelected extends DestinationRouteListEvent {}

class DestinationRouteIsNotLoaded extends DestinationRouteListEvent {}

class DestinationRoutesBloc
    extends Bloc<DestinationRouteListEvent, DestinationRouteState> {
  DestinationRoutesBloc() : super(DestinationRouteState.notLoaded) {
    on<DestinationRouteIsSelected>(
        (event, emit) => emit(DestinationRouteState.selected));
    on<DestinationRouteIsLoaded>(
        (event, emit) => emit(DestinationRouteState.loaded));
    on<DestinationRouteIsNotSelected>(
        (event, emit) => emit(DestinationRouteState.notSelected));
    on<DestinationRouteIsNotLoaded>(
        (event, emit) => emit(DestinationRouteState.notLoaded));
  }
}
