part of 'timer_bloc.dart';

abstract class TimerEvent extends Equatable {
  const TimerEvent();

  @override
  List<Object> get props => [];
}

class TimerStarted extends TimerEvent {
  final int duration;
  const TimerStarted({required this.duration});
}

class TimerPaused extends TimerEvent {}

class TimerResumed extends TimerEvent {}

class TimerReset extends TimerEvent {}

class _TimerTicked extends TimerEvent {
  final int duration;
  const _TimerTicked({required this.duration});
}

class TimerCompleted extends TimerEvent {}
class TimerFailed extends TimerEvent {}
