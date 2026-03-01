part of 'fruit_bloc.dart';

abstract class FruitEvent extends Equatable {
  const FruitEvent();

  @override
  List<Object> get props => [];
}

class LoadFruitData extends FruitEvent {}

class AddExperience extends FruitEvent {
  final int amount;
  const AddExperience(this.amount);
}

class SwitchActiveFruit extends FruitEvent {
  final String fruitId;
  const SwitchActiveFruit(this.fruitId);
}
