import 'package:flutter/material.dart';
import 'package:horizontal_scrolling_game/color_table.dart';

// グリッドの個々のパネル
class Pixel extends StatelessWidget {
  final Color color;
  final String childStr;

  const Pixel({
    super.key,
    required this.color,
    required this.childStr,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(1.0),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(4.0),
      ),
      child: Center(
        child: Text(
          childStr,
          style: const TextStyle(
            color: ColorTable.primaryWhiteColor,
          ),
        ),
      ),
    );
  }
}
