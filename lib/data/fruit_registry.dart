import 'package:flutter/material.dart';

class FruitDefinition {
  final String id;
  final String name;
  final String description;
  final int unlockMinutes; // Total focus time required
  final Color baseColor;

  const FruitDefinition({
    required this.id,
    required this.name,
    required this.description,
    required this.unlockMinutes,
    required this.baseColor,
  });
}

class FruitRegistry {
  static const List<FruitDefinition> allFruits = [
    FruitDefinition(
      id: 'apple',
      name: 'Apple',
      description: 'The reliable starter. A symbol of knowledge.',
      unlockMinutes: 0,
      baseColor: Colors.redAccent,
    ),
    FruitDefinition(
      id: 'lemon',
      name: 'Lemon',
      description: 'Zesty and bright. Unlocks after 2 hours of focus.',
      unlockMinutes: 120, // 2 Hours
      baseColor: Colors.yellow,
    ),
    FruitDefinition(
      id: 'plum',
      name: 'Plum',
      description: 'Deep and calm. Unlocks after 5 hours of focus.',
      unlockMinutes: 300, // 5 Hours
      baseColor: Colors.purple,
    ),
    FruitDefinition(
      id: 'cherry',
      name: 'Cherry',
      description: 'Small but sweet. Unlocks after 10 hours of focus.',
      unlockMinutes: 600, // 10 Hours
      baseColor: Colors.pink,
    ),
    FruitDefinition(
      id: 'dragonfruit',
      name: 'Dragonfruit',
      description: 'Exotic and legendary. Unlocks after 24 hours of focus.',
      unlockMinutes: 1440, // 24 Hours
      baseColor: Colors.pinkAccent,
    ),
  ];

  static FruitDefinition getById(String id) {
    return allFruits.firstWhere(
      (f) => f.id == id,
      orElse: () => allFruits.first,
    );
  }
}
