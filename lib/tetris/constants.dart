import 'package:flutter/material.dart';

// グリッド設定
int rowlength = 10;
int colLength = 15;

// 移動方向
enum MoveDirection {
  left,
  right,
  down,
}

// ピースの形
enum Tetromino {
  L,
  J,
  I,
  O,
  S,
  Z,
  T,
}

// ピースごとの色
const Map<Tetromino, Color> tetrominoColors = {
  Tetromino.L: Colors.white,
  Tetromino.J: Colors.green,
  Tetromino.I: Colors.blue,
  Tetromino.O: Colors.lightGreen,
  Tetromino.S: Colors.lightBlue,
  Tetromino.Z: Colors.red,
  Tetromino.T: Colors.purple,
};
