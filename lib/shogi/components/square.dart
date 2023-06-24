import 'package:flutter/material.dart';
import 'package:horizontal_scrolling_game/color_table.dart';
import 'package:horizontal_scrolling_game/shogi/components/piece.dart';

class Square extends StatelessWidget {
  final ShogiPiece? piece;
  final bool isSelected;
  final bool isValidMove;
  final void Function()? onTap;
  final bool isSelectingDropPosition;
  final bool isHoheiLineUpVertically;

  const Square({
    super.key,
    required this.piece,
    required this.isSelected,
    required this.isValidMove,
    required this.onTap,
    required this.isSelectingDropPosition,
    required this.isHoheiLineUpVertically,
  });

  @override
  Widget build(BuildContext context) {
    Color? squareColor;

    // 座標の状態によって背景色を変化
    if (isSelectingDropPosition && piece == null && !isHoheiLineUpVertically) {
      squareColor = Colors.green[200];
    } else if (isSelected) {
      squareColor = ColorTable.primaryGreenColor; // 駒を選択中
    } else if (isValidMove) {
      squareColor = Colors.green[200]; // 選択している駒が移動可能
    } else {
      squareColor = Colors.orange[100];
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
