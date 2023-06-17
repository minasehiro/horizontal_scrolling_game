enum ShogiPieceType { ousho, gyokusho, hisya, kakugyo, kinsho, ginsho, keima, kyousya, hohei }

class ShogiPiece {
  final ShogiPieceType type;
  final bool isally;
  final String imagePath;

  ShogiPiece({
    required this.type,
    required this.isally,
    required this.imagePath,
  });
}
