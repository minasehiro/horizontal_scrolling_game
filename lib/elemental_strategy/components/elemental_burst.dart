import '../../constants.dart';

class ElementalBurst {
  final String name;
  final String voice;
  final ElementType elementType;
  final int coolTime;
  final double damage;
  final List<List<int>> damageRange;

  ElementalBurst({
    required this.name,
    required this.voice,
    required this.elementType,
    required this.coolTime,
    required this.damage,
    required this.damageRange,
  });

  bool isCoolTime(int turnLastTriggered, int currentTurn) {
    if (turnLastTriggered == 0) {
      return false;
    }
    return (currentTurn - turnLastTriggered) > coolTime ? false : true;
  }
}
