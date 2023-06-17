import 'package:horizontal_scrolling_game/shogi/components/piece.dart';

ShogiPiece turnOverPiece(ShogiPiece piece) {
  String currentKeyString = piece.isally ? "up" : "down";
  String newKeyString = piece.isally ? "down" : "up";
  String newImagePath = piece.imagePath.replaceFirst(currentKeyString, newKeyString);

  return ShogiPiece(
    type: piece.type,
    isally: !piece.isally,
    imagePath: newImagePath,
  );
}
