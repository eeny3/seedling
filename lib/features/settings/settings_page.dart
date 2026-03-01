import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../../data/database_service.dart';
import '../../models/session.dart';
import '../orchard/bloc/fruit_bloc.dart';
import '../laboratory/bloc/lab_bloc.dart';
import '../timer/bloc/timer_bloc.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _notificationsEnabled = true;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _notificationsEnabled = prefs.getBool('notifications_enabled') ?? true;
      _isLoading = false;
    });
  }

  Future<void> _toggleNotifications(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notifications_enabled', value);
    setState(() {
      _notificationsEnabled = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator()) 
        : ListView(
        children: [
          SwitchListTile(
            secondary: Icon(
              _notificationsEnabled ? Icons.notifications_active : Icons.notifications_off,
              color: _notificationsEnabled ? Colors.green : Colors.grey,
            ),
            title: const Text('Timer Alerts'),
            subtitle: const Text('Receive a notification when your focus session ends.'),
            value: _notificationsEnabled,
            activeColor: Colors.green,
            onChanged: _toggleNotifications,
          ),
          const Divider(),
          const ListTile(
            leading: Icon(Icons.info_outline),
            title: Text('About Seedling'),
            subtitle: Text('Version 1.0.0'),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.delete_forever, color: Colors.red),
            title: const Text('Reset All Data'),
            onTap: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Factory Reset?'),
                  content: const Text('This will delete all fruits, history, and nectar. This cannot be undone.'),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
                    TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Reset', style: TextStyle(color: Colors.red))),
                  ],
                ),
              );

              if (confirm == true && context.mounted) {
                await _performReset(context);
              }
            },
          ),
          const SizedBox(height: 40),
          // --- DEBUG SECTION ---
          const Padding(
            padding: EdgeInsets.only(left: 16.0),
            child: Text("DEVELOPER ZONE", style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
          ),
          ListTile(
            leading: const Icon(Icons.bug_report, color: Colors.purple),
            title: const Text('Inject Test Data'),
            subtitle: const Text('Simulate 1 week of usage'),
            onTap: () async {
               await _injectFakeData(context);
            },
          ),
        ],
      ),
    );
  }

  Future<void> _performReset(BuildContext context) async {
    final db = GetIt.I<DatabaseService>();
    await db.fruitBox.clear();
    await db.sessionBox.clear();
    await db.userBox.clear();
    
    // Reset Onboarding flag
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('hasSeenOnboarding');

    if (context.mounted) {
       // Refresh Blocs
       context.read<FruitBloc>().add(LoadFruitData());
       context.read<LabBloc>().add(LoadLabData());
       context.read<TimerBloc>().add(TimerReset());
       
       ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('App Reset Complete')));
    }
  }

  Future<void> _injectFakeData(BuildContext context) async {
    final db = GetIt.I<DatabaseService>();
    
    // 1. Give Nectar
    await db.addNectar(5000); // Rich!

    // 2. Add History (Fake last 7 days)
    final now = DateTime.now();
    
    for (int i = 0; i < 7; i++) {
      // Create 3 sessions per day
      for (int j = 0; j < 3; j++) {
        final duration = 25;
        final session = Session(
          id: const Uuid().v4(),
          startTime: now.subtract(Duration(days: i, hours: j * 2)),
          durationMinutes: duration,
          isCompleted: true, // Mostly success
          nectarEarned: 100,
        );
        await db.saveSession(session);
      }
    }
    
    // 4. Level up the active fruit
    final active = await db.getActiveFruit();
    final leveled = active.copyWith(level: 4, xp: 2800); 
    await db.updateFruit(leveled);

    if (context.mounted) {
       context.read<FruitBloc>().add(LoadFruitData());
       context.read<LabBloc>().add(LoadLabData());
       ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Fake Data Injected! Enjoy.')));
    }
  }
}
