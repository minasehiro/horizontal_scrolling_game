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
      case CharacterType.kazuha:
        returnStr = "楓原万葉";
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
      default:
    }
    return returnStr;
  }
}
