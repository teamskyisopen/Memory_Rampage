import 'package:flutter/material.dart';
import 'package:memory_rampage/utils/colors.dart';

class StatsPanel extends StatelessWidget {
  final int level;
  final String time;
  final int lives;
  final int score;

  const StatsPanel({
    super.key,
    required this.level,
    required this.time,
    required this.lives,
    required this.score,
  });

  Widget _buildStatItem(IconData icon, String label, String value) {
    return Expanded(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 16, color: gameTextSecondary),
              const SizedBox(width: 4),
              Text(label, style: const TextStyle(fontSize: 16, color: gameTextSecondary)),
            ],
          ),
          const SizedBox(height: 2),
          Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(16.0),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 8.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem(Icons.layers, 'Level', level.toString()),
                _buildStatItem(Icons.timer_outlined, 'Time', time),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem(Icons.favorite, 'Lives', lives.toString()),
                _buildStatItem(Icons.star, 'Score', score.toString()),
              ],
            ),
          ],
        ),
      ),
    );
  }
}