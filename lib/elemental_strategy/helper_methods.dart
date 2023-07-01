import 'dart:math';

import 'components/character.dart';
import 'components/genshin_element.dart';
import 'constants.dart';

// 元素粒子の種類と発生位置を計算
Map<String, dynamic> buildElementalParticle(elements, rows, cols) {
  Random random = Random();
  GenshinElement derivedElement;
  List<int> derivedCoordinates;

  derivedElement = elements[random.nextInt(elements.length)];
  derivedCoordinates = [rows[random.nextInt(rows.length)], cols[random.nextInt(cols.length)]];

  return {
    "element": derivedElement,
    "coordinates": derivedCoordinates,
  };
}

// キャラクターが移動可能な座標を配列で返す
List<List<int>> calculateRawValidMoves(List<List<Character?>> field, int row, int col, Character? piece) {
  if (piece == null) {
    return [];
  }

  List<List<int>> candidateMoves = [];

  switch (piece.type) {
    case CharacterType.kazuha:
    case CharacterType.venti:
    case CharacterType.xiao:
    case CharacterType.yanfei:
      var directions = [
        [-1, 0], // 上
        [1, 0], // 下
        [0, -1], // 左
        [0, 1], // 右
        [-1, -1], // 左上
        [-1, 1], // 右上
        [1, -1], // 左下
        [1, 1], // 右下
      ];

      for (var direction in directions) {
        var newRow = row + (direction[0]);
        var newCol = col + (direction[1]);

        // フィールドから出た場合
        if (!isInField(newRow, newCol)) {
          continue;
        }

        // 対象の座標にキャラクターがいる
        if (field[newRow][newCol] != null) {
          // 対象のキャラクターが敵
          if (field[newRow][newCol]!.isAlly != piece.isAlly) {
            candidateMoves.add([newRow, newCol]);
          }
          continue;
        }

        candidateMoves.add([newRow, newCol]);
      }

      break;
    default:
  }

  return candidateMoves;
}

// 対象の座標がフィールドにあるか
bool isInField(int row, int col) {
  return row >= 0 && row < 8 && col >= 0 && col < 8;
}

// キャラクターを自分のものにする
Character turnOverPiece(Character character) {
  String currentDirectionString = character.isAlly ? "up" : "down"; // 画像パスから検索する文字列
  String newDirectionString = character.isAlly ? "down" : "up"; // 置き換える文字列
  String newImagePath = character.imagePath.replaceFirst(currentDirectionString, newDirectionString); // 画像パスの置き換え

  return Character(
    type: character.type,
    elementType: character.elementType,
    isAlly: !character.isAlly,
    imagePath: newImagePath,
    elementEnergy: 0,
  );
}
