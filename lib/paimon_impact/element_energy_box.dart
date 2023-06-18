// 元素エネルギー描画用
import 'package:flutter/material.dart';
import 'package:horizontal_scrolling_game/color_table.dart';
import 'package:horizontal_scrolling_game/paimon_impact/element_energy_class.dart';

class ElementEnergyBox extends StatelessWidget {
  final ElementEnergy elementEnergy;

  const ElementEnergyBox({
    super.key,
    required this.elementEnergy,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment(
        elementEnergy.coordinate[0],
        (2 * elementEnergy.coordinate[1] + elementEnergy.height) / (2 - elementEnergy.height),
      ),
      child: Stack(
        alignment: AlignmentDirectional.center,
        children: [
          Container(
            width: (MediaQuery.of(context).size.width * elementEnergy.width / 2) * 1.1,
            height: (MediaQuery.of(context).size.height * 3 / 4 * elementEnergy.height / 3) * 1.1,
            decoration: const BoxDecoration(
              color: ColorTable.primaryWhiteColor,
              shape: BoxShape.circle,
            ),
          ),
          Image.asset(
            'lib/assets/images/paimon_impact/elements/${elementEnergy.elementType}.png',
            width: MediaQuery.of(context).size.width * elementEnergy.width / 2,
            height: MediaQuery.of(context).size.height * 3 / 4 * elementEnergy.height / 3,
            fit: BoxFit.fill,
          ),
        ],
      ),
    );
  }
}
