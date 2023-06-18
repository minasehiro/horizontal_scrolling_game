enum ShogiPieceType {
  ousho,
  gyokusho,
  hisya,
  promotedHisya,
  kakugyo,
  promotedKakugyo,
  kinsho,
  ginsho,
  promotedGinsho,
  keima,
  promotedKeima,
  kyousya,
  promotedKyousya,
  hohei,
  promotedHohei,
}

class ShogiPiece {
  final ShogiPieceType type;
  final bool isally;
  final String imagePath;
  final bool isPromoted;

  ShogiPiece({
    required this.type,
    required this.isally,
    required this.imagePath,
    required this.isPromoted,
  });
}
