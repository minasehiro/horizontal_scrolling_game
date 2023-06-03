import 'package:flutter/material.dart';

class Paimon extends StatelessWidget {
  final double paimonX;
  final double paimonY;
  final double paimonWidth;
  final double paimonHeight;

  const Paimon({
    super.key,
    required this.paimonX,
    required this.paimonY,
    required this.paimonWidth,
    required this.paimonHeight,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment(paimonX, (2 * paimonY + paimonHeight) / (2 - paimonHeight)),
      child: Image.asset(
        'lib/assets/images/paimon.png',
        width: MediaQuery.of(context).size.height * paimonHeight / 2,
        height: MediaQuery.of(context).size.height * paimonHeight / 2,
        fit: BoxFit.fill,
      ),
    );
  }
}
