import 'package:flutter/material.dart';
import '../models/achievement.dart';

final List<Achievement> achievements = [

  Achievement(
    title: "Heroic",
    description: "Reached Heroic Rank",
    icon: Icons.workspace_premium,
    color: Colors.red,
    unlocked: true,
  ),

  Achievement(
    title: "Champion",
    description: "Won 25 Tournaments",
    icon: Icons.emoji_events,
    color: Colors.orange,
    unlocked: true,
  ),

  Achievement(
    title: "MVP",
    description: "Earned 95 MVP Awards",
    icon: Icons.star,
    color: Colors.amber,
    unlocked: true,
  ),

  Achievement(
    title: "Top 100",
    description: "Reached Top 100 Players",
    icon: Icons.military_tech,
    color: Colors.blue,
    unlocked: true,
  ),

  Achievement(
    title: "Sharpshooter",
    description: "1000+ Headshots",
    icon: Icons.gps_fixed,
    color: Colors.green,
    unlocked: true,
  ),

  Achievement(
    title: "Survivor",
    description: "Played 500 Matches",
    icon: Icons.shield,
    color: Colors.teal,
    unlocked: false,
  ),

  Achievement(
    title: "Speed Killer",
    description: "5000 Total Kills",
    icon: Icons.flash_on,
    color: Colors.deepOrange,
    unlocked: false,
  ),

  Achievement(
    title: "Rising Star",
    description: "Won First Tournament",
    icon: Icons.trending_up,
    color: Colors.purple,
    unlocked: true,
  ),
];