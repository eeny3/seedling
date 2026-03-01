part of 'timer_bloc.dart';

enum TimerStatus { initial, running, paused, success, failure }

class TimerState extends Equatable {
  final int duration;
  final TimerStatus status;

  const TimerState({
    required this.duration,
    this.status = TimerStatus.initial,
  });

  @override
  List<Object> get props => [duration, status];
  
  @override
  String toString() => 'TimerState { duration: $duration, status: $status }';
}
