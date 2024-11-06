import 'package:flutter_bloc/flutter_bloc.dart';

enum DriverState { selected, loaded, notSelected, notLoaded }

abstract class DriverListEvent {}

class DriverIsSelected extends DriverListEvent {}

class DriverIsLoaded extends DriverListEvent {}

class DriverIsNotSelected extends DriverListEvent {}

class DriverIsNotLoaded extends DriverListEvent {}

class ShowDriversBloc extends Bloc<DriverListEvent, DriverState> {
  ShowDriversBloc() : super(DriverState.notLoaded) {
    on<DriverIsSelected>((event, emit) => emit(DriverState.selected));
    on<DriverIsLoaded>((event, emit) => emit(DriverState.loaded));
    on<DriverIsNotSelected>((event, emit) => emit(DriverState.notSelected));
    on<DriverIsNotLoaded>((event, emit) => emit(DriverState.notLoaded));
  }
}
