import 'package:horizontal_scrolling_game/elemental_strategy/components/piece.dart';

// 駒を自分のものにする
ShogiPiece turnOverPiece(ShogiPiece piece) {
  String currentKeyString = piece.isally ? "up" : "down"; // 画像パスから検索する文字列
  String newKeyString = piece.isally ? "down" : "up"; // 置き換える文字列
  String newImagePath = piece.imagePath.replaceFirst(currentKeyString, newKeyString); // 画像パスの置き換え
  newImagePath = newImagePath.replaceFirst("promoted_", ""); // 成り駒を取った場合、画像パスを変更

  return ShogiPiece(
    type: piece.type,
    isally: !piece.isally,
    imagePath: newImagePath,
    isPromoted: false,
  );
}

String toKanjiNumeral(int int) {
  String returnStr = "";
  switch (int) {
    case 1:
      returnStr = "一";
      break;
    case 2:
      returnStr = "二";
      break;
    case 3:
      returnStr = "三";
      break;
    case 4:
      returnStr = "四";
      break;
    case 5:
      returnStr = "五";
      break;
    case 6:
      returnStr = "六";
      break;
    case 7:
      returnStr = "七";
      break;
    case 8:
      returnStr = "八";
      break;
    case 9:
      returnStr = "九";
      break;
    default:
  }

  return returnStr;
}
