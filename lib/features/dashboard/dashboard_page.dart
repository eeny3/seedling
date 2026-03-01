import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:get_it/get_it.dart';
import '../../data/database_service.dart';
import '../../data/theme_registry.dart';
import '../home/view/home_view.dart';
import '../orchard/view/orchard_page.dart';
import '../laboratory/view/laboratory_page.dart';
import '../history/history_page.dart';
import '../settings/settings_page.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  int _selectedIndex = 0;
  
  static const List<Widget> _widgetOptions = <Widget>[
    HomeView(),
    OrchardPage(),
    LaboratoryPage(),
    HistoryPage(),
    SettingsPage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: GetIt.I<DatabaseService>().userBox.listenable(keys: ['active_theme']),
      builder: (context, box, _) {
        final themeId = box.get('active_theme', defaultValue: 'default');
        final theme = ThemeRegistry.getById(themeId);
        final hasImage = theme.assetPath != null;

        return Container(
          decoration: BoxDecoration(
            color: Colors.white, // Default base
            image: hasImage ? DecorationImage(
              image: AssetImage(theme.assetPath!),
              fit: BoxFit.cover,
              colorFilter: ColorFilter.mode(
                Colors.black.withOpacity(0.3), 
                BlendMode.darken,
              ),
            ) : null,
          ),
          child: Scaffold(
            backgroundColor: hasImage ? Colors.transparent : Colors.white,
            extendBody: true, // Key: Allows body to go behind BottomNavBar
            body: _widgetOptions.elementAt(_selectedIndex),
            bottomNavigationBar: Container(
              decoration: hasImage ? BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [
                    Colors.black.withOpacity(0.8),
                    Colors.transparent,
                  ],
                ),
              ) : null,
              child: BottomNavigationBar(
                items: const <BottomNavigationBarItem>[
                  BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
                  BottomNavigationBarItem(icon: Icon(Icons.local_florist), label: 'Garden'),
                  BottomNavigationBarItem(icon: Icon(Icons.science), label: 'Lab'),
                  BottomNavigationBarItem(icon: Icon(Icons.history), label: 'History'),
                  BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Settings'),
                ],
                currentIndex: _selectedIndex,
                onTap: _onItemTapped,
                
                // Styling for Transparent Mode
                backgroundColor: hasImage ? Colors.transparent : Colors.white,
                elevation: hasImage ? 0 : 8,
                type: BottomNavigationBarType.fixed,
                
                selectedItemColor: hasImage ? Colors.greenAccent : Colors.green[800],
                unselectedItemColor: hasImage ? Colors.white60 : Colors.grey,
              ),
            ),
          ),
        );
      },
    );
  }
}
