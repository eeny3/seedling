import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import '../bloc/fruit_bloc.dart';
import '../../shared/fruit_image.dart';
import '../../../data/fruit_registry.dart';
import '../../../data/database_service.dart';

class OrchardPage extends StatelessWidget {
  const OrchardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('The Orchard')),
      body: BlocBuilder<FruitBloc, FruitState>(
        builder: (context, state) {
           // We wrap the whole body in the builder so both lists react to state changes automatically
           if (state is! FruitLoaded) return const Center(child: CircularProgressIndicator());
           
           return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
                  child: Text("My Garden", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                ),
                
                // Existing Fruits Grid
                _MyGardenGrid(state: state),

                const Padding(
                  padding: EdgeInsets.fromLTRB(16, 24, 16, 8),
                  child: Text("Seed Discovery", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                ),
                
                // Unlocks List
                _DiscoveryList(inventory: state.inventory),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _MyGardenGrid extends StatelessWidget {
  final FruitLoaded state;
  const _MyGardenGrid({required this.state});

  @override
  Widget build(BuildContext context) {
    final inventory = state.inventory;
    final activeId = state.activeFruit.id;

    if (inventory.isEmpty) {
       return const Padding(
         padding: EdgeInsets.all(16.0),
         child: Text("You have no plants yet."),
       );
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 0.8,
      ),
      itemCount: inventory.length,
      itemBuilder: (context, index) {
        final fruit = inventory[index];
        final isActive = fruit.id == activeId;

        return Card(
          elevation: isActive ? 8 : 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: isActive 
                ? const BorderSide(color: Colors.green, width: 3) 
                : BorderSide.none,
          ),
          child: InkWell(
            onTap: () {
              if (!isActive) {
                context.read<FruitBloc>().add(SwitchActiveFruit(fruit.id));
                ScaffoldMessenger.of(context).showSnackBar(
                   SnackBar(content: Text('Switched to ${fruit.type}')),
                );
              }
            },
            borderRadius: BorderRadius.circular(16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                 FruitImage(
                   type: fruit.type, 
                   level: fruit.level,
                   size: 80,
                 ),
                 const SizedBox(height: 12),
                 Text(
                   fruit.type,
                   style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                 ),
                 Text(
                   "Lvl ${fruit.level}",
                   style: const TextStyle(color: Colors.grey),
                 ),
                 const SizedBox(height: 8),
                 if (isActive)
                   const Chip(label: Text("Active"), backgroundColor: Colors.greenAccent)
                 else
                   Text("${fruit.xp} XP", style: const TextStyle(fontSize: 12)),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _DiscoveryList extends StatelessWidget {
  final List<dynamic> inventory;
  const _DiscoveryList({required this.inventory});

  @override
  Widget build(BuildContext context) {
    final db = GetIt.I<DatabaseService>();
    final totalMinutes = db.totalFocusMinutes;
    // Normalize casing for comparison
    final ownedTypes = inventory.map((f) => f.type.toLowerCase()).toSet();

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: FruitRegistry.allFruits.length,
      itemBuilder: (context, index) {
        final def = FruitRegistry.allFruits[index];
        final isUnlocked = totalMinutes >= def.unlockMinutes;
        // Check if we own it by checking if our inventory set contains the registry name
        final isOwned = ownedTypes.contains(def.name.toLowerCase()); 
        
        if (isOwned) return const SizedBox.shrink(); 

        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: isUnlocked ? def.baseColor.withOpacity(0.2) : Colors.grey[300],
              child: Icon(
                isUnlocked ? Icons.local_florist : Icons.lock,
                color: isUnlocked ? def.baseColor : Colors.grey,
              ),
            ),
            title: Text(def.name),
            subtitle: Text(isUnlocked ? def.description : "Focus for ${def.unlockMinutes} min to unlock"),
            trailing: isUnlocked 
                ? ElevatedButton(
                    onPressed: () async {
                       await db.unlockAndPlantFruit(def.name); 
                       if (context.mounted) {
                         // Reload the BLOC, which triggers the Builder above to rebuild
                         // This updates 'inventory' passed to this widget, hiding the item
                         context.read<FruitBloc>().add(LoadFruitData());
                         ScaffoldMessenger.of(context).showSnackBar(
                           SnackBar(content: Text("Planted ${def.name}!")),
                         );
                       }
                    }, 
                    child: const Text("Plant")
                  )
                : Text(
                    "${((def.unlockMinutes - totalMinutes) / 60).ceil()}h left",
                    style: const TextStyle(color: Colors.grey),
                  ),
          ),
        );
      },
    );
  }
}
