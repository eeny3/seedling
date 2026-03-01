import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../data/database_service.dart';
import '../../../models/fruit.dart';

part 'lab_event.dart';
part 'lab_state.dart';

class LabBloc extends Bloc<LabEvent, LabState> {
  final DatabaseService _databaseService;

  LabBloc({required DatabaseService databaseService})
      : _databaseService = databaseService,
        super(LabLoading()) {
    on<LoadLabData>(_onLoadData);
    on<PurchaseUpgrade>(_onPurchaseUpgrade);
  }

  Future<void> _onLoadData(LoadLabData event, Emitter<LabState> emit) async {
    try {
      final nectar = _databaseService.nectar;
      final fruit = await _databaseService.getActiveFruit();
      emit(LabLoaded(nectarBalance: nectar, activeFruit: fruit));
    } catch (e) {
      emit(LabError("Failed to open Laboratory"));
    }
  }

  Future<void> _onPurchaseUpgrade(PurchaseUpgrade event, Emitter<LabState> emit) async {
    if (state is LabLoaded) {
      final currentNectar = _databaseService.nectar;
      
      if (currentNectar >= event.cost) {
        // Deduct Cost
        await _databaseService.spendNectar(event.cost);
        
        // Apply Upgrade
        final currentFruit = (state as LabLoaded).activeFruit;
        Fruit updatedFruit;
        
        if (event.type == UpgradeType.zest) {
            updatedFruit = currentFruit.copyWith(zest: currentFruit.zest + 0.1);
        } else {
            updatedFruit = currentFruit.copyWith(durability: currentFruit.durability + 1);
        }
        
        await _databaseService.updateFruit(updatedFruit);
        
        // Refresh State
        emit(LabLoaded(
            nectarBalance: _databaseService.nectar, 
            activeFruit: updatedFruit
        ));
      } else {
        emit(LabError("Not enough Nectar!"));
        // Re-emit loaded state immediately so error is temporary or handled via listener
        // But for simplicity in this architecture, we might just stay in Loaded and let UI handle validation.
        // Actually, let's just reload.
        add(LoadLabData());
      }
    }
  }
}
