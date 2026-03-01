import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/lab_bloc.dart';
import '../../orchard/bloc/fruit_bloc.dart'; // To refresh orchard after upgrade

class LaboratoryPage extends StatefulWidget {
  const LaboratoryPage({super.key});

  @override
  State<LaboratoryPage> createState() => _LaboratoryPageState();
}

class _LaboratoryPageState extends State<LaboratoryPage> {
  @override
  void initState() {
    super.initState();
    context.read<LabBloc>().add(LoadLabData());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Alchemy Laboratory')),
      body: BlocConsumer<LabBloc, LabState>(
        listener: (context, state) {
           if (state is LabError) {
             ScaffoldMessenger.of(context).showSnackBar(
               SnackBar(content: Text(state.message), backgroundColor: Colors.red),
             );
           }
           // Sync external blocs if needed
           if (state is LabLoaded) {
             context.read<FruitBloc>().add(LoadFruitData()); 
           }
        },
        builder: (context, state) {
          if (state is! LabLoaded) {
            return const Center(child: CircularProgressIndicator());
          }

          final fruit = state.activeFruit;
          final nectar = state.nectarBalance;

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header: Current Resources
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.amber.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.amber),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("Available Nectar:", style: TextStyle(fontSize: 18)),
                      Row(
                        children: [
                          const Icon(Icons.local_drink, color: Colors.amber),
                          const SizedBox(width: 8),
                          Text("$nectar", style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                        ],
                      )
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                
                Text("Upgrading: ${fruit.type}", style: Theme.of(context).textTheme.titleLarge),
                const Divider(),
                const SizedBox(height: 10),

                // Upgrade Card: Zest
                _UpgradeCard(
                  title: "Concentrate Zest",
                  description: "Increase Nectar yield by 10%.",
                  currentValue: "${(fruit.zest * 100).toInt()}%",
                  cost: 200,
                  icon: Icons.flash_on,
                  canAfford: nectar >= 200,
                  onBuy: () {
                    context.read<LabBloc>().add(const PurchaseUpgrade(
                      type: UpgradeType.zest, 
                      cost: 200
                    ));
                  },
                ),
                
                const SizedBox(height: 16),

                // Upgrade Card: Durability
                _UpgradeCard(
                  title: "Fortify Skin",
                  description: "Survive 1 failed session without penalty.",
                  currentValue: "${fruit.durability} Shields",
                  cost: 500,
                  icon: Icons.shield,
                  canAfford: nectar >= 500,
                  onBuy: () {
                    context.read<LabBloc>().add(const PurchaseUpgrade(
                      type: UpgradeType.durability, 
                      cost: 500
                    ));
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _UpgradeCard extends StatelessWidget {
  final String title;
  final String description;
  final String currentValue;
  final int cost;
  final IconData icon;
  final bool canAfford;
  final VoidCallback onBuy;

  const _UpgradeCard({
    required this.title,
    required this.description,
    required this.currentValue,
    required this.cost,
    required this.icon,
    required this.canAfford,
    required this.onBuy,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 32, color: Colors.green),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  Text(description, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                  const SizedBox(height: 8),
                  Text("Current: $currentValue", style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green)),
                ],
              ),
            ),
            ElevatedButton(
              onPressed: canAfford ? onBuy : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.amber,
                foregroundColor: Colors.black,
              ),
              child: Text("$cost N"),
            ),
          ],
        ),
      ),
    );
  }
}
