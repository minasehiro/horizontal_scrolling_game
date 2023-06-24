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
  final bool isAlly;
  final String imagePath;
  final bool isPromoted;

  ShogiPiece({
    required this.type,
    required this.isAlly,
    required this.imagePath,
    required this.isPromoted,
  });

  String typeStr() {
    String returnStr = "";
    switch (type) {
      case ShogiPieceType.ousho:
        returnStr = "王";
        break;
      case ShogiPieceType.gyokusho:
        returnStr = "玉";
        break;
      case ShogiPieceType.hisya:
        returnStr = "飛";
        break;
      case ShogiPieceType.promotedHisya:
        returnStr = "龍";
        break;
      case ShogiPieceType.kakugyo:
        returnStr = "角";
        break;
      case ShogiPieceType.promotedKakugyo:
        returnStr = "馬";
        break;
      case ShogiPieceType.kinsho:
        returnStr = "金";
        break;
      case ShogiPieceType.ginsho:
        returnStr = "銀";
        break;
      case ShogiPieceType.promotedGinsho:
        returnStr = "全";
        break;
      case ShogiPieceType.keima:
        returnStr = "桂";
        break;
      case ShogiPieceType.promotedKeima:
        returnStr = "圭";
        break;
      case ShogiPieceType.kyousya:
        returnStr = "香";
        break;
      case ShogiPieceType.promotedKyousya:
        returnStr = "杏";
        break;
      case ShogiPieceType.hohei:
        returnStr = "歩";
        break;
      case ShogiPieceType.promotedHohei:
        returnStr = "と";
        break;
      default:
    }
    return returnStr;
  }
}
