import 'package:flutter/material.dart';
import 'package:horizontal_scrolling_game/elemental_strategy/components/genshin_element.dart';

import '../../color_table.dart';
import 'character.dart';
import 'character_coin.dart';

class Square extends StatelessWidget {
  final Character? piece;
  final bool isSelected;
  final bool isValidMove;
  final bool canAttackRange;
  final void Function()? onTap;
  final GenshinElement? element;

  const Square({
    super.key,
    required this.piece,
    required this.isSelected,
    required this.isValidMove,
    required this.canAttackRange,
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
    } else if (canAttackRange) {
      squareColor = Colors.yellow; // 攻撃可能範囲
    } else if (isValidMove) {
      squareColor = Colors.blue[200]; // 選択しているキャラクターが移動可能
    } else {
      squareColor = Colors.blueGrey[200];
    }

    if (piece != null) {
      displayWidget = CharacterCoin(character: piece, imagePath: piece!.imagePath);
    } else if (element != null) {
      displayWidget = Stack(alignment: AlignmentDirectional.center, children: [
        Container(
          margin: const EdgeInsets.all(20.0),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.8),
            shape: BoxShape.circle,
          ),
        ),
        Image.asset(
          element!.imagePath,
          width: 18.0,
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
