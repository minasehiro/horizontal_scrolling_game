import '../../constants.dart';

class ElementalSkill {
  final String name;
  final String voice;
  final ElementType elementType;
  final int coolTime;
  final double damage;
  final List<List<int>> damageRange;
  final double numberOfParticlesGenerated;

  ElementalSkill({
    required this.name,
    required this.voice,
    required this.elementType,
    required this.coolTime,
    required this.damage,
    required this.damageRange,
    required this.numberOfParticlesGenerated,
  });

  bool isCoolTime(int turnLastTriggered, int currentTurn) {
    if (turnLastTriggered == 0) {
      return false;
    }
    return (currentTurn - turnLastTriggered) > coolTime ? false : true;
  }
}
