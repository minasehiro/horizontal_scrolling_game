import '../constants.dart';

class Damage {
  ElementType elementType;
  double value;
  bool isCritical;

  Damage({
    required this.elementType,
    required this.value,
    required this.isCritical,
  });
}
