part of 'fruit_bloc.dart';

abstract class FruitState extends Equatable {
  const FruitState();
  
  @override
  List<Object> get props => [];
}

class FruitLoading extends FruitState {}

class FruitLoaded extends FruitState {
  final Fruit activeFruit;
  final List<Fruit> inventory;

  const FruitLoaded({
    required this.activeFruit,
    this.inventory = const [],
  });

  @override
  List<Object> get props => [activeFruit, inventory];
}

class FruitError extends FruitState {
  final String message;
  const FruitError(this.message);
}
