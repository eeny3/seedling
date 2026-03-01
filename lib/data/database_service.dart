import 'package:hive_flutter/hive_flutter.dart';
import 'package:uuid/uuid.dart';
import '../models/fruit.dart';
import '../models/session.dart';

class DatabaseService {
  static const String fruitBoxName = 'fruitBox';
  static const String sessionBoxName = 'sessionBox';
  static const String userBoxName = 'userBox'; 

  Future<void> init() async {
    await Hive.initFlutter();
    
    try {
        Hive.registerAdapter(FruitAdapter());
        Hive.registerAdapter(SessionAdapter());
    } catch (e) {
        // Adapters might be registered already
    }

    await Hive.openBox<Fruit>(fruitBoxName);
    await Hive.openBox<Session>(sessionBoxName);
    await Hive.openBox(userBoxName);
  }

  Box<Fruit> get fruitBox => Hive.box<Fruit>(fruitBoxName);
  Box<Session> get sessionBox => Hive.box<Session>(sessionBoxName);
  Box get userBox => Hive.box(userBoxName);

  // --- Currency (Nectar) ---
  int get nectar => userBox.get('nectar', defaultValue: 0);
  
  Future<void> addNectar(int amount) async {
    final current = nectar;
    await userBox.put('nectar', current + amount);
  }
  
  Future<void> spendNectar(int amount) async {
    final current = nectar;
    if (current >= amount) {
      await userBox.put('nectar', current - amount);
    }
  }

  // --- Audio Shop ---
  List<String> get unlockedSoundIds {
    return userBox.get('unlocked_sounds', defaultValue: ['rain', 'forest', 'stream']).cast<String>();
  }

  Future<void> unlockSound(String id) async {
    final list = unlockedSoundIds;
    if (!list.contains(id)) {
      list.add(id);
      await userBox.put('unlocked_sounds', list);
    }
  }

  // --- Achievements ---
  List<String> get unlockedAchievements {
    return userBox.get('unlocked_achievements', defaultValue: <String>[]).cast<String>();
  }

  Future<void> unlockAchievement(String id) async {
    final list = unlockedAchievements;
    if (!list.contains(id)) {
      list.add(id);
      await userBox.put('unlocked_achievements', list);
    }
  }

  // --- Themes ---
  List<String> get unlockedThemeIds {
    return userBox.get('unlocked_themes', defaultValue: ['default']).cast<String>();
  }

  String get activeThemeId => userBox.get('active_theme', defaultValue: 'default');

  Future<void> unlockTheme(String id) async {
    final list = unlockedThemeIds;
    if (!list.contains(id)) {
      list.add(id);
      await userBox.put('unlocked_themes', list);
    }
  }

  Future<void> setActiveTheme(String id) async {
    await userBox.put('active_theme', id);
  }

  // --- Stats ---
  int get totalFocusMinutes => userBox.get('totalFocusMinutes', defaultValue: 0);
  int get totalSessionsCompleted => sessionBox.values.where((s) => s.isCompleted).length;

  Future<void> addFocusMinutes(int minutes) async {
    final current = totalFocusMinutes;
    await userBox.put('totalFocusMinutes', current + minutes);
  }

  // --- Active Fruit Management ---
  
  Future<Fruit> getActiveFruit() async {
    final activeId = userBox.get('activeFruitId');
    
    if (activeId != null && fruitBox.containsKey(activeId)) {
      return fruitBox.get(activeId)!;
    }
    
    if (fruitBox.isNotEmpty) {
      final firstFruit = fruitBox.values.first;
      await setActiveFruitId(firstFruit.id);
      return firstFruit;
    }
    
    return await _createStarterFruit();
  }

  Future<Fruit> _createStarterFruit() async {
    final id = const Uuid().v4();
    final newFruit = Fruit(
      id: id,
      type: 'Apple',
      level: 1,
      xp: 0,
      lastHarvest: DateTime.now(),
    );
    
    await fruitBox.put(id, newFruit);
    await setActiveFruitId(id);
    return newFruit;
  }
  
  Future<void> setActiveFruitId(String id) async {
    await userBox.put('activeFruitId', id);
  }

  Future<void> updateFruit(Fruit fruit) async {
    await fruitBox.put(fruit.id, fruit);
  }
  
  Future<void> unlockAndPlantFruit(String typeName) async {
    final id = const Uuid().v4();
    final newFruit = Fruit(
      id: id,
      type: typeName,
      level: 1,
      xp: 0,
      lastHarvest: DateTime.now(),
    );
    await fruitBox.put(id, newFruit);
  }

  List<Fruit> getAllFruits() {
    return fruitBox.values.toList();
  }

  // --- Session Persistence ---
  Future<void> saveSession(Session session) async {
    await sessionBox.add(session);
    if (session.isCompleted) {
      await addFocusMinutes(session.durationMinutes);
    }
  }

  List<Session> getHistory() {
    final list = sessionBox.values.toList();
    list.sort((a, b) => b.startTime.compareTo(a.startTime));
    return list;
  }

  Future<void> saveSessionEndTime(DateTime endTime) async {
      await userBox.put('currentSessionEndTime', endTime.toIso8601String());
  }

  DateTime? getSessionEndTime() {
      final str = userBox.get('currentSessionEndTime');
      if (str == null) return null;
      return DateTime.parse(str);
  }

  Future<void> clearSession() async {
      await userBox.delete('currentSessionEndTime');
  }
}
