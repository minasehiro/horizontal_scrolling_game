import '../constants.dart';

class Character {
  final CharacterType type;
  final ElementType elementType;
  final bool isAlly;
  final String imagePath;
  final double elementEnergy;

  Character({
    required this.type,
    required this.elementType,
    required this.isAlly,
    required this.imagePath,
    required this.elementEnergy,
  });

  String name() {
    String returnStr = "";
    switch (type) {
      case CharacterType.kaedeharaKazuha:
        returnStr = "楓原万葉";
        break;
      case CharacterType.kamisatoAyaka:
        returnStr = "神里綾華";
        break;
      case CharacterType.raidenShougun:
        returnStr = "雷電将軍";
        break;
      case CharacterType.xingqiu:
        returnStr = "行秋";
        break;
      case CharacterType.venti:
        returnStr = "ウェンティ";
        break;
      case CharacterType.xiao:
        returnStr = "魈";
        break;
      case CharacterType.yanfei:
        returnStr = "煙緋";
        break;
      case CharacterType.nahida:
        returnStr = "ナヒーダ";
        break;
      case CharacterType.zhongli:
        returnStr = "鐘離";
        break;
      case CharacterType.yaeMiko:
        returnStr = "八重神子";
        break;
      case CharacterType.cyno:
        returnStr = "セノ";
        break;
      default:
    }
    return returnStr;
  }
}
