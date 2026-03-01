import 'package:flutter/material.dart';

class AppTheme {
  final String id;
  final String name;
  final String? assetPath; // Nullable = Solid Color
  final int cost;
  final Color textColor; 

  const AppTheme({
    required this.id,
    required this.name,
    this.assetPath,
    required this.cost,
    required this.textColor,
  });
}

class ThemeRegistry {
  static const List<AppTheme> allThemes = [
    // DEFAULT (Clean)
    AppTheme(
      id: 'default',
      name: 'Clean Slate',
      assetPath: null, // No image
      cost: 0,
      textColor: Colors.black87,
    ),
    
    // PURCHASABLE
    AppTheme(
      id: 'greenhouse',
      name: 'Classic Greenhouse',
      assetPath: 'assets/backgrounds/greenhouse.jpg',
      cost: 200,
      textColor: Colors.white,
    ),
    AppTheme(
      id: 'rainy',
      name: 'Rainy Window',
      assetPath: 'assets/backgrounds/rainy.jpg',
      cost: 500,
      textColor: Colors.white,
    ),
    AppTheme(
      id: 'sunset',
      name: 'Pixel Sunset',
      assetPath: 'assets/backgrounds/sunset.jpg',
      cost: 1000,
      textColor: Colors.white,
    ),
    AppTheme(
      id: 'night',
      name: 'Night Garden',
      assetPath: 'assets/backgrounds/night.jpg',
      cost: 1500,
      textColor: Colors.white,
    ),
  ];

  static AppTheme getById(String id) {
    return allThemes.firstWhere(
      (t) => t.id == id,
      orElse: () => allThemes.first,
    );
  }
}
