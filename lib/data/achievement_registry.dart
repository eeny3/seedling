import 'package:flutter/material.dart';

class Achievement {
  final String id;
  final String title;
  final String description;
  final IconData icon;
  final Color color;

  const Achievement({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
  });
}

class AchievementRegistry {
  static const List<Achievement> all = [
    Achievement(
      id: 'first_step',
      title: 'First Step',
      description: 'Complete your first focus session.',
      icon: Icons.flag,
      color: Colors.blue,
    ),
    Achievement(
      id: 'early_bird',
      title: 'Early Bird',
      description: 'Complete a session before 8:00 AM.',
      icon: Icons.wb_sunny,
      color: Colors.orange,
    ),
    Achievement(
      id: 'night_owl',
      title: 'Night Owl',
      description: 'Complete a session after 10:00 PM.',
      icon: Icons.nights_stay,
      color: Colors.deepPurple,
    ),
    Achievement(
      id: 'dedicated',
      title: 'Dedicated',
      description: 'Complete 10 total sessions.',
      icon: Icons.star,
      color: Colors.redAccent,
    ),
    Achievement(
      id: 'master',
      title: 'Focus Master',
      description: 'Accumulate 24 hours of total focus time.',
      icon: Icons.workspace_premium,
      color: Colors.amber,
    ),
  ];
}
