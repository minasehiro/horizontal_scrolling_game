import 'package:flutter/material.dart';
import 'package:horizontal_scrolling_game/tetris/constants.dart';
import 'package:horizontal_scrolling_game/tetris/tetris.dart';

class Piece {
  // ピースの形
  Tetromino type;

  Piece({required this.type});

  List<int> position = [];

  Color get color {
    return tetrominoColors[type] ?? Colors.white;
  }

  int rotationState = 1;

  // ピースを配置
  void initializePiece() {
    switch (type) {
      case Tetromino.L:
        position = [-26, -16, -6, -5];
        break;
      case Tetromino.J:
        position = [-25, -15, -5, -6];
        break;
      case Tetromino.I:
        position = [-4, -5, -6, -7];
        break;
      case Tetromino.O:
        position = [-15, -16, -5, -6];
        break;
      case Tetromino.S:
        position = [-15, -14, -6, -5];
        break;
      case Tetromino.Z:
        position = [-17, -16, -6, -5];
        break;
      case Tetromino.T:
        position = [-26, -16, -6, -15];
        break;
      default:
    }
  }

  // direction に合わせピースを移動
  void movePiece(MoveDirection direction) {
    switch (direction) {
      case MoveDirection.down:
        for (int i = 0; i < position.length; i++) {
          position[i] += rowlength;
        }
        break;
      case MoveDirection.left:
        for (int i = 0; i < position.length; i++) {
          position[i] -= 1;
        }
        break;
      case MoveDirection.right:
        for (int i = 0; i < position.length; i++) {
          position[i] += 1;
        }
        break;
      default:
    }
  }

  // ピースを回転
  void rotatePiece() {
    List<int> newPosition = [];

    switch (type) {
      case Tetromino.L:
        switch (rotationState) {
          case 0:
            newPosition = [
              position[1] - rowlength,
              position[1],
              position[1] + rowlength,
              position[1] + rowlength + 1,
            ];

            if (isValidPiecePosition(newPosition)) {
              position = newPosition;
              rotationState = (rotationState + 1) % 4;
            }

            break;
          case 1:
            newPosition = [
              position[1] - 1,
              position[1],
              position[1] + 1,
              position[1] + rowlength - 1,
            ];

            if (isValidPiecePosition(newPosition)) {
              position = newPosition;
              rotationState = (rotationState + 1) % 4;
            }

            break;
          case 2:
            newPosition = [
              position[1] + rowlength,
              position[1],
              position[1] - rowlength,
              position[1] - rowlength - 1,
            ];

            if (isValidPiecePosition(newPosition)) {
              position = newPosition;
              rotationState = (rotationState + 1) % 4;
            }

            break;
          case 3:
            newPosition = [
              position[1] - rowlength + 1,
              position[1],
              position[1] + 1,
              position[1] - 1,
            ];

            if (isValidPiecePosition(newPosition)) {
              position = newPosition;
              rotationState = (rotationState + 1) % 4;
            }

            break;
        }
        break;
      case Tetromino.J:
        switch (rotationState) {
          case 0:
            newPosition = [
              position[1] - rowlength,
              position[1],
              position[1] + rowlength,
              position[1] + rowlength - 1,
            ];

            if (isValidPiecePosition(newPosition)) {
              position = newPosition;
              rotationState = (rotationState + 1) % 4;
            }

            break;
          case 1:
            newPosition = [
              position[1] - rowlength - 1,
              position[1],
              position[1] - 1,
              position[1] + 1,
            ];

            if (isValidPiecePosition(newPosition)) {
              position = newPosition;
              rotationState = (rotationState + 1) % 4;
            }

            break;
          case 2:
            newPosition = [
              position[1] + rowlength,
              position[1],
              position[1] - rowlength,
              position[1] - rowlength + 1,
            ];

            if (isValidPiecePosition(newPosition)) {
              position = newPosition;
              rotationState = (rotationState + 1) % 4;
            }

            break;
          case 3:
            newPosition = [
              position[1] + 1,
              position[1],
              position[1] - 1,
              position[1] + rowlength + 1,
            ];

            if (isValidPiecePosition(newPosition)) {
              position = newPosition;
              rotationState = (rotationState + 1) % 4;
            }

            break;
        }
        break;
      case Tetromino.I:
        switch (rotationState) {
          case 0:
            newPosition = [
              position[1] - 1,
              position[1],
              position[1] + 1,
              position[1] + 2,
            ];

            if (isValidPiecePosition(newPosition)) {
              position = newPosition;
              rotationState = (rotationState + 1) % 4;
            }

            break;
          case 1:
            newPosition = [
              position[1] - rowlength,
              position[1],
              position[1] + rowlength,
              position[1] + 2 * rowlength,
            ];

            if (isValidPiecePosition(newPosition)) {
              position = newPosition;
              rotationState = (rotationState + 1) % 4;
            }

            break;
          case 2:
            newPosition = [
              position[1] + 1,
              position[1],
              position[1] - 1,
              position[1] - 2,
            ];

            if (isValidPiecePosition(newPosition)) {
              position = newPosition;
              rotationState = (rotationState + 1) % 4;
            }

            break;
          case 3:
            newPosition = [
              position[1] + rowlength,
              position[1],
              position[1] - rowlength,
              position[1] - 2 * rowlength,
            ];

            if (isValidPiecePosition(newPosition)) {
              position = newPosition;
              rotationState = (rotationState + 1) % 4;
            }

            break;
        }
        break;
      case Tetromino.O:
        break;
      case Tetromino.S:
        switch (rotationState) {
          case 0:
            newPosition = [
              position[1],
              position[1] + 1,
              position[1] + rowlength - 1,
              position[1] + rowlength,
            ];

            if (isValidPiecePosition(newPosition)) {
              position = newPosition;
              rotationState = (rotationState + 1) % 4;
            }

            break;
          case 1:
            newPosition = [
              position[0] - rowlength,
              position[0],
              position[0] + 1,
              position[0] + rowlength + 1,
            ];

            if (isValidPiecePosition(newPosition)) {
              position = newPosition;
              rotationState = (rotationState + 1) % 4;
            }

            break;
          case 2:
            newPosition = [
              position[1],
              position[1] + 1,
              position[1] + rowlength - 1,
              position[1] + rowlength,
            ];

            if (isValidPiecePosition(newPosition)) {
              position = newPosition;
              rotationState = (rotationState + 1) % 4;
            }

            break;
          case 3:
            newPosition = [
              position[0] - rowlength,
              position[0],
              position[0] + 1,
              position[0] + rowlength + 1,
            ];

            if (isValidPiecePosition(newPosition)) {
              position = newPosition;
              rotationState = (rotationState + 1) % 4;
            }

            break;
        }
        break;
      case Tetromino.Z:
        switch (rotationState) {
          case 0:
            newPosition = [
              position[0] + rowlength - 2,
              position[1],
              position[2] + rowlength - 1,
              position[3] + 1,
            ];

            if (isValidPiecePosition(newPosition)) {
              position = newPosition;
              rotationState = (rotationState + 1) % 4;
            }

            break;
          case 1:
            newPosition = [
              position[0] - rowlength + 2,
              position[1],
              position[2] - rowlength + 1,
              position[3] - 1,
            ];

            if (isValidPiecePosition(newPosition)) {
              position = newPosition;
              rotationState = (rotationState + 1) % 4;
            }

            break;
          case 2:
            newPosition = [
              position[0] + rowlength - 2,
              position[1],
              position[2] + rowlength - 1,
              position[3] + 1,
            ];

            if (isValidPiecePosition(newPosition)) {
              position = newPosition;
              rotationState = (rotationState + 1) % 4;
            }

            break;
          case 3:
            newPosition = [
              position[0] - rowlength + 2,
              position[1],
              position[2] - rowlength + 1,
              position[3] - 1,
            ];

            if (isValidPiecePosition(newPosition)) {
              position = newPosition;
              rotationState = (rotationState + 1) % 4;
            }

            break;
        }
        break;
      case Tetromino.T:
        switch (rotationState) {
          case 0:
            newPosition = [
              position[2] - rowlength,
              position[2],
              position[2] + 1,
              position[2] + rowlength,
            ];

            if (isValidPiecePosition(newPosition)) {
              position = newPosition;
              rotationState = (rotationState + 1) % 4;
            }

            break;
          case 1:
            newPosition = [
              position[1] - 1,
              position[1],
              position[1] + 1,
              position[1] + rowlength,
            ];

            if (isValidPiecePosition(newPosition)) {
              position = newPosition;
              rotationState = (rotationState + 1) % 4;
            }

            break;
          case 2:
            newPosition = [
              position[1] - rowlength,
              position[1] - 1,
              position[1],
              position[1] + rowlength,
            ];

            if (isValidPiecePosition(newPosition)) {
              position = newPosition;
              rotationState = (rotationState + 1) % 4;
            }

            break;
          case 3:
            newPosition = [
              position[2] - rowlength,
              position[2] - 1,
              position[2],
              position[2] + 1,
            ];

            if (isValidPiecePosition(newPosition)) {
              position = newPosition;
              rotationState = (rotationState + 1) % 4;
            }

            break;
        }
        break;
      default:
    }
  }

  // 画面外に出ていたり、他のピースと衝突していないか Pixel 単位で判定
  bool isValidPosition(int position) {
    int row = (position / rowlength).floor();
    int col = position % rowlength;

    if (row < 0 || col < 0 || gameBoard[row][col] != null) {
      return false;
    } else {
      return true;
    }
  }

  // 画面外に出ていたり、他のピースと衝突していないか Piece 単位で判定
  bool isValidPiecePosition(List<int> piecePosition) {
    bool firstColOccupied = false;
    bool lastColOccupied = false;

    for (int position in piecePosition) {
      if (!isValidPosition(position)) {
        return false;
      }

      // X座標
      int col = position % rowlength;

      // 画面の左端
      if (col == 0) {
        firstColOccupied = true;
      }

      // 画面の右端
      if (col == rowlength - 1) {
        lastColOccupied = true;
      }
    }

    return !(firstColOccupied && lastColOccupied);
  }
}
