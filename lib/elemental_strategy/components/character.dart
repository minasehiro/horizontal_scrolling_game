import '../constants.dart';
import 'elemental_burst.dart';
import 'elemental_skill.dart';

class Character {
  final CharacterType type;
  final ElementType elementType;
  final bool isAlly;
  final String imagePath;
  final double elementEnergy;
  final double hitPoint;
  final int currentRow;
  final int currentCol;
  final ElementalSkill skill;
  final int turnLastTriggeredSkill;
  final ElementalBurst burst;
  final int turnLastTriggeredBurst;

  Character({
    required this.type,
    required this.elementType,
    required this.isAlly,
    required this.imagePath,
    required this.elementEnergy,
    required this.hitPoint,
    required this.currentRow,
    required this.currentCol,
    required this.skill,
    required this.turnLastTriggeredSkill,
    required this.burst,
    required this.turnLastTriggeredBurst,
  });

  // キャラクター名
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
