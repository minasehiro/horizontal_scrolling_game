import 'package:horizontal_scrolling_game/shogi/components/piece.dart';

ShogiPiece turnOverPiece(ShogiPiece piece) {
  String currentKeyString = piece.isally ? "up" : "down";
  String newKeyString = piece.isally ? "down" : "up";
  String newImagePath = piece.imagePath.replaceFirst(currentKeyString, newKeyString);

  return ShogiPiece(
    type: piece.type,
    isally: !piece.isally,
    imagePath: newImagePath,
    isPromoted: false,
  );
}

// 成り
ShogiPiece promotePiece(ShogiPiece piece) {
  String keyString = piece.isally ? "up" : "down";
  String newImagePath = piece.imagePath.replaceFirst(keyString, "promoted_$keyString");
  ShogiPieceType newShogiPieceType = piece.type;

  switch (piece.type) {
    case ShogiPieceType.hisya:
      newShogiPieceType = ShogiPieceType.promotedHisya;
      break;
    case ShogiPieceType.kakugyo:
      newShogiPieceType = ShogiPieceType.promotedKakugyo;
      break;
    case ShogiPieceType.keima:
      newShogiPieceType = ShogiPieceType.promotedKeima;
      break;
    case ShogiPieceType.kyousya:
      newShogiPieceType = ShogiPieceType.kyousya;
      break;
    case ShogiPieceType.ginsho:
      newShogiPieceType = ShogiPieceType.ginsho;
      break;
    case ShogiPieceType.hohei:
      newShogiPieceType = ShogiPieceType.promotedHohei;
      break;
    default:
  }

  return ShogiPiece(
    type: newShogiPieceType,
    isally: piece.isally,
    imagePath: newImagePath,
    isPromoted: false,
  );
}
