import 'package:flutter_bloc/flutter_bloc.dart';

enum ButtonState { isDisabled, startNavigation, stopNavigation, isEnabled }

abstract class ButtonEvent {}

class ButtonIsDisabled extends ButtonEvent {}

class ButtonIsEnabled extends ButtonEvent {}

class ButtonStartNavigation extends ButtonEvent {}

class ButtonStopNavigation extends ButtonEvent {}

class CurrentLocationBloc extends Bloc<ButtonEvent, ButtonState> {
  CurrentLocationBloc() : super(ButtonState.isDisabled) {
    on<ButtonIsDisabled>((event, emit) => emit(ButtonState.isDisabled));
    on<ButtonIsEnabled>((event, emit) => emit(ButtonState.isEnabled));
    on<ButtonStartNavigation>(
        (event, emit) => emit(ButtonState.startNavigation));
    on<ButtonStopNavigation>((event, emit) => emit(ButtonState.stopNavigation));
  }
}
