import 'package:flutter/material.dart';
import 'package:horizontal_scrolling_game/elemental_strategy/components/genshin_element.dart';

import '../../color_table.dart';
import 'character.dart';
import 'character_coin.dart';

class Square extends StatelessWidget {
  final Character? piece;
  final bool isSelected;
  final bool isValidMove;
  final void Function()? onTap;
  final GenshinElement? element;

  const Square({
    super.key,
    required this.piece,
    required this.isSelected,
    required this.isValidMove,
    required this.onTap,
    required this.element,
  });

  @override
  Widget build(BuildContext context) {
    Color? squareColor;
    Widget? displayWidget;

    // 座標の状態によって背景色を変化
    if (isSelected) {
      squareColor = Colors.blue; // キャラクターを選択中
    } else if (isValidMove) {
      squareColor = Colors.blue[200]; // 選択しているキャラクターが移動可能
    } else {
      squareColor = Colors.blueGrey[300];
    }

    if (piece != null) {
      displayWidget = CharacterCoin(character: piece, imagePath: piece!.imagePath);
    } else if (element != null) {
      displayWidget = Stack(alignment: AlignmentDirectional.center, children: [
        Container(
          margin: const EdgeInsets.all(10.0),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.8),
            shape: BoxShape.circle,
          ),
        ),
        Image.asset(
          element!.imagePath,
          width: 20.0,
        ),
      ]);
    } else {
      null;
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
        child: displayWidget,
      ),
    );
  }
}
