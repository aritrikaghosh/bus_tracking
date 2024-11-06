import 'package:flutter_bloc/flutter_bloc.dart';

enum DeleteRouteState { selected, loaded, notSelected, notLoaded }

abstract class RouteListEvent {}

class RouteIsSelected extends RouteListEvent {}

class RouteIsLoaded extends RouteListEvent {}

class RouteIsNotSelected extends RouteListEvent {}

class RouteIsNotLoaded extends RouteListEvent {}

class DeleteRoutesBloc extends Bloc<RouteListEvent, DeleteRouteState> {
  DeleteRoutesBloc() : super(DeleteRouteState.notLoaded) {
    on<RouteIsSelected>((event, emit) => emit(DeleteRouteState.selected));
    on<RouteIsLoaded>((event, emit) => emit(DeleteRouteState.loaded));
    on<RouteIsNotSelected>((event, emit) => emit(DeleteRouteState.notSelected));
    on<RouteIsNotLoaded>((event, emit) => emit(DeleteRouteState.notLoaded));
  }
}
