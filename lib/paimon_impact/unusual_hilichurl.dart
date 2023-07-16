import 'package:flutter/material.dart';

class UnusualHilichurl extends StatelessWidget {
  final double xCoordinate;
  final double yCoordinate;
  final double width;
  final double height;

  const UnusualHilichurl({
    super.key,
    required this.xCoordinate,
    required this.yCoordinate,
    required this.width,
    required this.height,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment(
        xCoordinate,
        (2 * yCoordinate + height) / (2 - height),
      ),
      child: Image.asset(
        'lib/assets/images/genshin/enemies/unusual_hilichurl.png',
        width: MediaQuery.of(context).size.height * height / 2,
        height: MediaQuery.of(context).size.height * height / 2,
        fit: BoxFit.fill,
      ),
    );
  }
}
