import 'package:hive/hive.dart';

part 'fruit.g.dart';

@HiveType(typeId: 0)
class Fruit extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String type; // e.g., 'Apple', 'Orange'

  @HiveField(2)
  int xp; // Sweetness

  @HiveField(3)
  int level; // Growth Stage (1-5)

  @HiveField(4)
  double zest; // Nectar Multiplier

  @HiveField(5)
  int durability; // Shield points

  @HiveField(6)
  DateTime lastHarvest;

  Fruit({
    required this.id,
    required this.type,
    this.xp = 0,
    this.level = 1,
    this.zest = 1.0,
    this.durability = 0,
    required this.lastHarvest,
  });

  // --- Growth Logic ---

  static const Map<int, int> xpThresholds = {
    1: 250,   // Seed -> Sprout
    2: 750,   // Sprout -> Young
    3: 1500,  // Young -> Mature
    4: 3000,  // Mature -> Ascended
  };

  int get maxXpForCurrentLevel => xpThresholds[level] ?? 3000;
  
  bool get isMaxLevel => level >= 5;

  double get progress {
    if (isMaxLevel) return 1.0;
    
    // Calculate XP relative to current level's start
    // Simple version: just % of max for this level.
    // For a more RPG feel, we might want cumulative, but let's stick to total XP.
    // Actually, usually in RPGs: Current XP / Target XP
    
    // Example: I have 300 XP. Level 2 (Threshold 750).
    // Progress should be roughly how close I am to 750.
    return xp / maxXpForCurrentLevel;
  }

  Fruit addXp(int amount) {
    int newXp = xp + amount;
    int newLevel = level;

    // Check for level up
    // We iterate to handle multi-level jumps if massive XP is gained
    while (newLevel < 5 && newXp >= (xpThresholds[newLevel] ?? 999999)) {
      newLevel++;
    }

    return copyWith(xp: newXp, level: newLevel);
  }

  Fruit copyWith({
    String? id,
    String? type,
    int? xp,
    int? level,
    double? zest,
    int? durability,
    DateTime? lastHarvest,
  }) {
    return Fruit(
      id: id ?? this.id,
      type: type ?? this.type,
      xp: xp ?? this.xp,
      level: level ?? this.level,
      zest: zest ?? this.zest,
      durability: durability ?? this.durability,
      lastHarvest: lastHarvest ?? this.lastHarvest,
    );
  }
}
