import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../data/database_service.dart';
import '../../../models/fruit.dart';

part 'fruit_event.dart';
part 'fruit_state.dart';

class FruitBloc extends Bloc<FruitEvent, FruitState> {
  final DatabaseService _databaseService;

  FruitBloc({required DatabaseService databaseService})
      : _databaseService = databaseService,
        super(FruitLoading()) {
    on<LoadFruitData>(_onLoadFruitData);
    on<AddExperience>(_onAddExperience);
    on<SwitchActiveFruit>(_onSwitchActiveFruit);
  }

  Future<void> _onLoadFruitData(
      LoadFruitData event, Emitter<FruitState> emit) async {
    try {
      final active = await _databaseService.getActiveFruit();
      final all = _databaseService.getAllFruits();
      emit(FruitLoaded(activeFruit: active, inventory: all));
    } catch (e) {
      emit(FruitError("Failed to load orchard: $e"));
    }
  }

  Future<void> _onAddExperience(
      AddExperience event, Emitter<FruitState> emit) async {
    if (state is FruitLoaded) {
      final currentLoaded = state as FruitLoaded;
      final active = currentLoaded.activeFruit;
      
      // Calculate XP with Zest multiplier if implemented later, 
      // for now raw amount.
      // Logic: XP = Base * FruitZestMultiplier (if we had it in model fully utilized)
      
      final updatedFruit = active.addXp(event.amount);
      await _databaseService.updateFruit(updatedFruit);
      
      // If level changed, we might want to show a special effect in UI, 
      // but state update is enough for now.
      
      emit(FruitLoaded(
        activeFruit: updatedFruit,
        inventory: _databaseService.getAllFruits(),
      ));
    }
  }

  Future<void> _onSwitchActiveFruit(
      SwitchActiveFruit event, Emitter<FruitState> emit) async {
    try {
      await _databaseService.setActiveFruitId(event.fruitId);
      add(LoadFruitData()); // Reload to ensure everything is synced
    } catch (e) {
      emit(FruitError("Failed to switch fruit"));
    }
  }
}
