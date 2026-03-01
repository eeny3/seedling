part of 'lab_bloc.dart';

abstract class LabState extends Equatable {
  const LabState();
  
  @override
  List<Object> get props => [];
}

class LabLoading extends LabState {}

class LabLoaded extends LabState {
  final int nectarBalance;
  final Fruit activeFruit;

  const LabLoaded({required this.nectarBalance, required this.activeFruit});
  
  @override
  List<Object> get props => [nectarBalance, activeFruit];
}

class LabError extends LabState {
  final String message;
  const LabError(this.message);
}
