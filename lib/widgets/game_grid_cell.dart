import 'package:flutter/material.dart';
import 'package:memory_rampage/utils/colors.dart';

enum CellState {
  initial, // Default gray
  flashing, // Green during flash
  revealedCorrect, // Green after correct tap
  revealedIncorrect, // Red after incorrect tap
}

class GameGridCell extends StatelessWidget {
  final CellState cellState;
  final VoidCallback onTap;
  final bool isClickable;
  final int? number;

  const GameGridCell({
    super.key,
    required this.cellState,
    required this.onTap,
    this.isClickable = true,
    this.number,
  });

  Color _getCellColor() {
    switch (cellState) {
      case CellState.flashing:
      case CellState.revealedCorrect:
        return gameCellFlashed;
      case CellState.revealedIncorrect:
        return Colors.red.shade300;
      case CellState.initial:
      default:
        return gameCellDefault;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isClickable ? onTap : null,
      child: AspectRatio(
        aspectRatio: 1,
        child: Container(
          margin: const EdgeInsets.all(4.0),
          decoration: BoxDecoration(
            color: _getCellColor(),
            borderRadius: BorderRadius.circular(4.0),
          ),
          child: Center(
            child: number != null
                ? Text(
                    '$number',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.normal,
                      color: Color.fromARGB(255, 99, 99, 99),
                    ),
                  )
                : null,
          ),
        ),
      ),
    );
  }

}
