import 'package:flutter/material.dart';

class Paimon extends StatelessWidget {
  final double paimonY;
  final double paimonWidth;
  final double paimonHeight;

  const Paimon({
    super.key,
    required this.paimonY,
    required this.paimonWidth,
    required this.paimonHeight,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment(0, (2 * paimonY + paimonHeight) / (2 - paimonHeight)),
      child: Image.asset(
        'lib/assets/images/genshin/characters/paimon.png',
        width: MediaQuery.of(context).size.height * paimonWidth / 2,
        height: MediaQuery.of(context).size.height * paimonHeight / 2,
        fit: BoxFit.fill,
      ),
    );
  }
}
