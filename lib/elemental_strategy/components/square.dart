import 'package:flutter/material.dart';

import '../../color_table.dart';
import 'character.dart';

class Square extends StatelessWidget {
  final Character? piece;
  final bool isSelected;
  final bool isValidMove;
  final void Function()? onTap;

  const Square({
    super.key,
    required this.piece,
    required this.isSelected,
    required this.isValidMove,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    Color? squareColor;

    // 座標の状態によって背景色を変化
    if (isSelected) {
      squareColor = ColorTable.primaryGreenColor; // キャラクターを選択中
    } else if (isValidMove) {
      squareColor = Colors.green[200]; // 選択しているキャラクターが移動可能
    } else {
      squareColor = Colors.brown[100];
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: squareColor,
          border: Border.all(
            width: 1.0,
            color: ColorTable.primaryBlackColor,
          ),
        ),
        child: piece != null
            ? Padding(
                padding: const EdgeInsets.all(5.0),
                child: Image.asset(piece!.imagePath),
              )
            : null,
      ),
    );
  }
}
