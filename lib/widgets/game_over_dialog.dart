import 'package:flutter/material.dart';
import 'package:memory_rampage/utils/colors.dart';

class GameOverDialog extends StatelessWidget {
  final int score;
  final int level;
  final bool isNewHighScore;
  final VoidCallback onRestart;
  final VoidCallback? onContinue; // Nullable if continue is not always available
  final VoidCallback onGoHome;

  const GameOverDialog({
    super.key,
    required this.score,
    required this.level,
    required this.isNewHighScore,
    required this.onRestart,
    this.onContinue,
    required this.onGoHome,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      titlePadding: const EdgeInsets.only(top: 24),
      title: Column(
        children: [
          if (isNewHighScore)
             const Icon(Icons.emoji_events, color: Colors.amber, size: 60),
          if (isNewHighScore)
            const Text(
              '🏆 New High Score! 🏆',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 22, color: gamePrimaryPurple, fontWeight: FontWeight.bold),
            ),
          const Text(
            'Game Over!',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 30, color: gamePrimaryPurple, fontWeight: FontWeight.bold),
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'You reached Level $level with a final score of $score.',
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 16, color: gameTextSecondary),
          ),
          const SizedBox(height: 24),
          if (onContinue != null)
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: onContinue,
                child: Text('Continue Level $level (Watch Ad)'),
              ),
            ),
          if (onContinue != null) const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onRestart,
              child: const Text('Restart Game (Level 1)'),
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              icon: const Icon(Icons.home),
              label: const Text('Go to Home'),
              onPressed: onGoHome,
            ),
          ),
        ],
      ),
      actionsPadding: const EdgeInsets.only(bottom: 16, right: 16, left: 16),
    );
  }
}