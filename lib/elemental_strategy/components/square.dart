import 'package:flutter/material.dart';
import 'package:horizontal_scrolling_game/elemental_strategy/components/genshin_element.dart';

import '../../color_table.dart';
import 'character.dart';

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
    String? imagePath;

    // 座標の状態によって表示する画像を変化
    if (piece != null) {
      imagePath = piece!.imagePath;
    } else if (element != null) {
      imagePath = element!.imagePath;
    }

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
        child: imagePath != null ? CharacterCoin(imagePath: imagePath) : null,
      ),
    );
  }
}

class CharacterCoin extends StatelessWidget {
  const CharacterCoin({
    Key? key,
    required this.imagePath,
  }) : super(key: key);

  final String? imagePath;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(5.0),
      child: Image.asset(imagePath!),
    );
  }
}
