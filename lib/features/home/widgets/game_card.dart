import 'package:flutter/material.dart';

import '../provider/home_provider.dart';

const _kCard = Color(0xFF171821);
const _kHairline = Color(0xFF2A2C38);
const _kTextSecondary = Color(0xFF9CA0AF);

class GameCard extends StatelessWidget {
  final GameItem game;
  final VoidCallback? onTap;

  const GameCard({super.key, required this.game, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 110,
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: _kCard,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: _kHairline),
        ),
        child: Column(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: game.iconAsset.isNotEmpty
                  ? Image.asset(game.iconAsset, width: 56, height: 56, fit: BoxFit.cover)
                  : Container(
                width: 56,
                height: 56,
                color: _kHairline,
                child: const Icon(Icons.videogame_asset, color: Colors.white54),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              game.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 2),
            Text(
              '${game.activePlayers} playing',
              style: const TextStyle(color: _kTextSecondary, fontSize: 9.5),
            ),
          ],
        ),
      ),
    );
  }
}