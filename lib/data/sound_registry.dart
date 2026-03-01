import 'package:flutter/material.dart';

class SoundTrack {
  final String id;
  final String name;
  final String filename;
  final int cost;
  final IconData icon;

  const SoundTrack({
    required this.id,
    required this.name,
    required this.filename,
    required this.cost,
    required this.icon,
  });
}

class SoundRegistry {
  static const List<SoundTrack> allTracks = [
    // FREE STARTERS
    SoundTrack(
      id: 'rain',
      name: 'Gentle Rain',
      filename: 'rain.mp3',
      cost: 0,
      icon: Icons.water_drop,
    ),
    SoundTrack(
      id: 'forest',
      name: 'Forest Wind',
      filename: 'forest.mp3',
      cost: 0,
      icon: Icons.forest,
    ),
    SoundTrack(
      id: 'stream',
      name: 'River Stream',
      filename: 'stream.mp3',
      cost: 0,
      icon: Icons.waves,
    ),

    // PREMIUM SHOP
    SoundTrack(
      id: 'ocean',
      name: 'Ocean Waves',
      filename: 'ocean.mp3',
      cost: 500,
      icon: Icons.surfing,
    ),
    SoundTrack(
      id: 'cafe',
      name: 'Coffee Shop',
      filename: 'cafe.mp3',
      cost: 800,
      icon: Icons.coffee,
    ),
    SoundTrack(
      id: 'night',
      name: 'Night Crickets',
      filename: 'night.mp3',
      cost: 1000,
      icon: Icons.nights_stay,
    ),
  ];
}
