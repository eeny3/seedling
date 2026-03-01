part of 'lab_bloc.dart';

abstract class LabEvent extends Equatable {
  const LabEvent();

  @override
  List<Object> get props => [];
}

class LoadLabData extends LabEvent {}

class PurchaseUpgrade extends LabEvent {
  final UpgradeType type;
  final int cost;
  
  const PurchaseUpgrade({required this.type, required this.cost});
}

enum UpgradeType {
  zest, // Multiplier
  durability // Shield
}
