enum ShogiPieceType {
  ousho,
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
      default:
    }
    return returnStr;
  }
}
