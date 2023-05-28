import 'package:flutter/material.dart';
import 'color_table.dart';

class GameBanner extends StatelessWidget {
  final bool isGameStarted;

  const GameBanner({
    super.key,
    required this.isGameStarted,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: const Alignment(0, -0.5),
      child: Text(
        isGameStarted ? '' : 'Paimon Impact',
        style: const TextStyle(
          color: ColorTable.primaryBlackColor,
          fontSize: 18,
          letterSpacing: 3,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
