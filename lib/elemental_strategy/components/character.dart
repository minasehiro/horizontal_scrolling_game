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

  String elementalBurstName() {
    switch (type) {
      case CharacterType.kaedeharaKazuha:
        return "万葉の一刀";
      case CharacterType.kamisatoAyaka:
        return "神里流・霜滅";
      case CharacterType.raidenShougun:
        return "奥義・夢想真説";
      case CharacterType.xingqiu:
        return "古華剣・裁雨留虹";
      case CharacterType.venti:
        return "風神の詩";
      case CharacterType.xiao:
        return "靖妖儺舞";
      case CharacterType.yanfei:
        return "契約成立";
      case CharacterType.nahida:
        return "心景幻成";
      case CharacterType.zhongli:
        return "天星";
      case CharacterType.yaeMiko:
        return "大密法・天狐顕現";
      case CharacterType.cyno:
        return "聖儀・狼駆憑走";
      default:
        return "";
    }
  }

  String elementalBurstVoice() {
    switch (type) {
      case CharacterType.kaedeharaKazuha:
        return "雲隠れ、雁鳴くとき";
      case CharacterType.kamisatoAyaka:
        return "櫻吹雪！";
      case CharacterType.raidenShougun:
        return "稲光、すなわち永遠なり";
      case CharacterType.xingqiu:
        return "古華奥義！";
      case CharacterType.venti:
        return "風だー！！！！";
      case CharacterType.xiao:
        return "喚くがいい！！！";
      case CharacterType.yanfei:
        return "丹書鉄契！";
      case CharacterType.nahida:
        return "知識を、あなたにも。";
      case CharacterType.zhongli:
        return "天道、ここに在り";
      case CharacterType.yaeMiko:
        return "雷光、いと美しきかな。";
      case CharacterType.cyno:
        return "この身で万象を粛清する！";
      default:
        return "";
    }
  }
}
