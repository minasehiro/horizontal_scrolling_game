import 'package:flutter/material.dart';
import 'character.dart';

import '../helper_methods.dart';
import 'damage.dart';

class CharacterCoin extends StatelessWidget {
  final Character? character;
  final String? imagePath;
  final Damage? damage;

  const CharacterCoin({
    Key? key,
    required this.character,
    required this.imagePath,
    required this.damage,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double elementEnergyPercent = character!.elementEnergy;
    double remainingHitPointPercentage = character!.hitPoint / 100;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (!character!.isAlly)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 50 * remainingHitPointPercentage,
                  height: 3,
                  decoration: BoxDecoration(
                    color: remainingHitPointPercentage <= 0.25 ? Colors.red : Colors.lightGreenAccent,
                    borderRadius: BorderRadius.circular(25),
                  ),
                ),
                Container(
                  width: 50 * (1 - remainingHitPointPercentage),
                  height: 3,
                  decoration: BoxDecoration(
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(25),
                  ),
                ),
              ],
            ),
          Stack(
            alignment: AlignmentDirectional.center,
            children: [
              PieChart(
                data: [
                  PieChartData(elementEnergyPercent >= 100 ? Colors.yellow : Colors.yellow.shade100, elementEnergyPercent),
                ],
                radius: 20,
                child: Image.asset(imagePath!),
              ),
              DamageNotation(
                isVisible: damage != null,
                damage: damage,
              ),
            ],
          ),
          if (character!.isAlly)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 50 * (1 - remainingHitPointPercentage),
                  height: 3,
                  decoration: BoxDecoration(
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(25),
                  ),
                ),
                Container(
                  width: 50 * remainingHitPointPercentage,
                  height: 3,
                  decoration: BoxDecoration(
                    color: remainingHitPointPercentage <= 0.25 ? Colors.red : Colors.lightGreenAccent,
                    borderRadius: BorderRadius.circular(25),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}

class DamageNotation extends StatelessWidget {
  final bool isVisible;
  final Damage? damage;

  const DamageNotation({
    required this.isVisible,
    required this.damage,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (isVisible) {
      return Container(
        padding: const EdgeInsets.all(8.0),
        child: Text(
          "25",
          style: TextStyle(
            fontSize: 25,
            fontWeight: FontWeight.bold,
            color: elementColor(damage!.elementType),
            shadows: [
              Shadow(
                color: Colors.black.withOpacity(0.5),
                offset: const Offset(1.0, 1.0),
                blurRadius: 5.0,
              ),
            ],
          ),
        ),
      );
    } else {
      return const Text("");
    }
  }
}

// this is used to pass data about chart values to the widget
class PieChartData {
  const PieChartData(this.color, this.percent);

  final Color color;
  final double percent;
}

// our pie chart widget
class PieChart extends StatelessWidget {
  PieChart({
    required this.data,
    required this.radius,
    this.strokeWidth = 3,
    this.child,
    Key? key,
  })  : // make sure sum of data is never ovr 100 percent
        assert(data.fold<double>(0, (sum, data) => sum + data.percent) <= 100),
        super(key: key);

  final List<PieChartData> data;
  // radius of chart
  final double radius;
  // width of stroke
  final double strokeWidth;
  // optional child; can be used for text for example
  final Widget? child;

  @override
  Widget build(context) {
    return CustomPaint(
      painter: _Painter(strokeWidth, data),
      size: Size.square(radius),
      child: SizedBox.square(
        // calc diameter
        dimension: radius * 2,
        child: Center(
          child: child,
        ),
      ),
    );
  }
}

// responsible for painting our chart
class _PainterData {
  const _PainterData(this.paint, this.radians);

  final Paint paint;
  final double radians;
}

class _Painter extends CustomPainter {
  _Painter(double strokeWidth, List<PieChartData> data) {
    // convert chart data to painter data
    dataList = data
        .map((e) => _PainterData(
              Paint()
                ..color = e.color
                ..style = PaintingStyle.stroke
                ..strokeWidth = strokeWidth
                ..strokeCap = StrokeCap.round,
              // remove padding from stroke
              (e.percent - _padding) * _percentInRadians,
            ))
        .toList();
  }

  static const _percentInRadians = 0.062831853071796;
  static const _padding = 0;
  static const _paddingInRadians = _percentInRadians * _padding;
  // 0 radians is to the right, but since we want to start from the top
  // we'll use -90 degrees in radians
  static const _startAngle = -1.570796 + _paddingInRadians / 2;

  late final List<_PainterData> dataList;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    // keep track of start angle for next stroke
    double startAngle = _startAngle;

    for (final data in dataList) {
      final path = Path()..addArc(rect, startAngle, data.radians);

      startAngle += data.radians + _paddingInRadians;

      canvas.drawPath(path, data.paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return oldDelegate != this;
  }
}
