import 'dart:async';
import 'package:flutter/material.dart';

import 'package:horizontal_scrolling_game/paimon_impact/element_energy_class.dart';
import 'package:horizontal_scrolling_game/home_page.dart';
import 'package:horizontal_scrolling_game/color_table.dart';
import 'package:horizontal_scrolling_game/paimon_impact/paimon.dart';
import 'package:horizontal_scrolling_game/paimon_impact/game_banner.dart';

class PaimonImpact extends StatefulWidget {
  const PaimonImpact({super.key});

  @override
  State<PaimonImpact> createState() => _PaimonImpactState();
}

class _PaimonImpactState extends State<PaimonImpact> with SingleTickerProviderStateMixin {
  // paimon が持つ情報
  static double paimonX = -0.5;
  static double paimonY = 0.85;
  double initPos = paimonY;
  double height = 1;
  double time = 0;
  double gravity = -3.9; // 重力
  double jumpVelocity = 2; // ジャンプの速さ（強さ）
  double paimonWidth = 0.15;
  double paimonHeight = 0.15;
  double elementsCount = 0;

  // ゲーム設定
  final Duration frameRate = const Duration(milliseconds: 50);
  final double scoreRangeStartXPoint = -0.05;
  final double scoreRangeEndXPoint = -0.1;
  bool isGameStarted = false;

  // 元素設定
  static double elementWidth = 0.15;
  static double elementHeight = 0.15;

  List<ElementEnergy> elementEnergies = [
    ElementEnergy(elementWidth, elementHeight, [0.75, 0.85], "pyro", true),
    ElementEnergy(elementWidth, elementHeight, [1.5, 0.85], "hydro", true),
    ElementEnergy(elementWidth, elementHeight, [2.2, 0.7], "anemo", true),
    ElementEnergy(elementWidth, elementHeight, [2.8, 0.5], "electro", true),
    ElementEnergy(elementWidth, elementHeight, [3.4, 0.66], "dendro", true),
    ElementEnergy(elementWidth, elementHeight, [3.9, 0.85], "cryo", true),
    ElementEnergy(elementWidth, elementHeight, [4.6, 0.79], "geo", true),
  ];

  // 元素爆発
  bool isShootElementalBurst = false;
  List<double> elementalBurstCoordinate = [0, 0];

  // デバイスの画面サイズ（高さ）
  late double deviceHeight;

  // 画像の横幅
  late double imageWidth;

  // アニメーションコントローラー
  late AnimationController controller;

  // アニメーション
  late Animation<RelativeRect> rectAnimation;

  void startGame() {
    isGameStarted = true;

    // 背景画像スクロールを開始
    controller.repeat();

    Timer.periodic(frameRate, (timer) {
      // 擬似的なジャンプの計算（放物線を描く）
      height = gravity * time * time + jumpVelocity * time;

      setState(() {
        var newY = initPos - height;
        newY = newY > 0.85 ? 0.85 : newY; // 下に抜け落ちないように
        newY = newY < -1 ? -1 : newY; // 上に突き抜けないように
        paimonY = newY;
      });

      // 元素を全て入手すると終了
      if (elementEnergies.isEmpty) {
        timer.cancel();
        controller.reset();
        _showDialog();
      }

      // 自動スクロール
      scrollBackground();

      time += 0.05;
    });
  }

  // 背景のスクロール
  void scrollBackground() {
    // 元素エネルギーとの衝突処理
    for (int i = 0; i < elementEnergies.length; i++) {
      var paimonLeftEdge = paimonX;
      var paimonRightEdge = paimonX + paimonWidth;
      var paimonTopEdge = paimonY - paimonHeight;
      var paimonBottomEdge = paimonY;

      var elementLeftEdge = elementEnergies[i].coordinate[0];
      var elementRightEdge = elementEnergies[i].coordinate[0] + elementEnergies[i].width;
      var elementTopEdge = elementEnergies[i].coordinate[1] - elementEnergies[i].height;
      var elementBottomEdge = elementEnergies[i].coordinate[1];

      // パイモンの左端が、元素エネルギーの左端より右 かつ 右端より左
      if ((paimonLeftEdge >= elementLeftEdge && paimonLeftEdge <= elementRightEdge ||
              // パイモンの右端が、元素エネルギーの左端より右 かつ 右端より左
              paimonRightEdge >= elementLeftEdge && paimonRightEdge <= elementRightEdge) &&
          // パイモンの上端が、元素エネルギーの下端より上 かつ 上端より下
          (paimonTopEdge <= elementBottomEdge && paimonTopEdge >= elementTopEdge ||
              // パイモンの下端が、元素エネルギーの下端より上 かつ 上端より下
              paimonBottomEdge <= elementBottomEdge && paimonBottomEdge >= elementTopEdge)) {
        elementsCount += 1;
        elementEnergies.removeAt(i);
      }
    }

    // 元素の移動処理
    for (int y = 0; y < elementEnergies.length; y++) {
      setState(() {
        elementEnergies[y].coordinate = [elementEnergies[y].coordinate[0] -= 0.05, elementEnergies[y].coordinate[1]];
      });

      // 左に消えていった元素エネルギーをループさせる
      if (elementEnergies[y].coordinate[0] < -1.5) {
        elementEnergies[y].coordinate = [elementEnergies[y].coordinate[0] += 3.5, elementEnergies[y].coordinate[1]];
      }
    }
  }

  void jump() {
    setState(() {
      time = 0;
      initPos = paimonY;
    });
  }

  bool paimonIsDead() {
    // 画面外に出た場合
    if (paimonY < -1 || paimonY > 1) {
      return true;
    }

    return false;
  }

  void resetGame() {
    Navigator.pop(context); // ダイアログを消す

    // 各種データをリセット
    setState(() {
      paimonX = -0.5;
      paimonY = 0.85;

      isGameStarted = false;
      time = 0;
      initPos = paimonY;
      elementEnergies = [
        ElementEnergy(elementWidth, elementHeight, [0.75, 0.85], "pyro", true),
        ElementEnergy(elementWidth, elementHeight, [1.5, 0.85], "hydro", true),
        ElementEnergy(elementWidth, elementHeight, [2.2, 0.7], "anemo", true),
        ElementEnergy(elementWidth, elementHeight, [2.8, 0.5], "electro", true),
        ElementEnergy(elementWidth, elementHeight, [3.4, 0.66], "dendro", true),
        ElementEnergy(elementWidth, elementHeight, [3.9, 0.85], "cryo", true),
        ElementEnergy(elementWidth, elementHeight, [4.6, 0.79], "geo", true),
      ];
      elementsCount = 0;

      isShootElementalBurst = false;
      elementalBurstCoordinate = [0, 0];
    });
  }

  // 元素爆発の発動
  shootElementalBurst() {
    if (elementsCount >= 5) {
      setState(() {
        elementalBurstCoordinate[0] = paimonWidth + 0.1;
        elementalBurstCoordinate[1] += paimonY + paimonHeight;
        isShootElementalBurst = true;
        elementsCount -= 5;
      });

      Timer.periodic(const Duration(milliseconds: 30), (timer) {
        setState(() {
          elementalBurstCoordinate[0] += 0.05;
        });

        if (elementalBurstCoordinate[0] > 1.5) {
          timer.cancel();
          isShootElementalBurst = false;
          elementalBurstCoordinate = [0, 0];
        }
      });
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // デバイスの画面サイズ（高さ）取得
    deviceHeight = MediaQuery.of(context).size.height;

    // 画像の縦横比
    double aspectRatio = 1.8;

    // 画像の横幅計算
    imageWidth = deviceHeight * aspectRatio;

    // コントローラー初期化
    controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    );

    // 背景画像のリピート
    rectAnimation = RelativeRectTween(
      begin: RelativeRect.fromLTRB(imageWidth, 0, 0, 0),
      end: RelativeRect.fromLTRB(0, 0, imageWidth, 0),
    ).animate(
      CurvedAnimation(parent: controller, curve: Curves.linear),
    );
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  void _showDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: ColorTable.primaryNavyColor,
          title: Center(
            child: Column(
              children: const [
                Text(
                  '元素をすべて集めました',
                  style: TextStyle(color: ColorTable.primaryWhiteColor),
                ),
              ],
            ),
          ),
          actions: [
            GestureDetector(
              onTap: () {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (context) => const HomePage()),
                );
              },
              child: ClipRRect(
                borderRadius: BorderRadius.circular(5),
                child: Container(
                  padding: const EdgeInsets.all(10),
                  color: ColorTable.primaryWhiteColor,
                  child: const Text(
                    'ホームに戻る',
                    style: TextStyle(color: ColorTable.primaryNavyColor),
                  ),
                ),
              ),
            ),
            GestureDetector(
              onTap: resetGame,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(5),
                child: Container(
                  padding: const EdgeInsets.all(10),
                  color: ColorTable.primaryWhiteColor,
                  child: const Text(
                    'もう一度旅に出る',
                    style: TextStyle(color: ColorTable.primaryNavyColor),
                  ),
                ),
              ),
            )
          ],
          actionsAlignment: MainAxisAlignment.center,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isGameStarted ? jump : startGame,
      child: Scaffold(
        body: Column(
          children: [
            Expanded(
              flex: 30,
              child: Container(
                color: ColorTable.primaryBlueColor,
                child: Center(
                  child: Stack(
                    children: [
                      PositionedTransition(
                        rect: rectAnimation,
                        child: OverflowBox(
                          maxWidth: imageWidth * 2, // 画像2枚分
                          maxHeight: deviceHeight, // 画面の高さに合わせる
                          child: Row(
                            children: <Widget>[
                              Image(
                                height: deviceHeight, // 画面の高さに合わせる
                                fit: BoxFit.fitHeight,
                                image: const AssetImage('lib/assets/images/background.png'),
                              ),
                              Image(
                                height: deviceHeight, // 画面の高さに合わせる
                                fit: BoxFit.fitHeight,
                                image: const AssetImage('lib/assets/images/background.png'),
                              ),
                            ],
                          ),
                        ),
                      ),
                      GameBanner(isGameStarted: isGameStarted),
                      Paimon(
                        paimonX: paimonX,
                        paimonY: paimonY,
                        paimonWidth: paimonWidth,
                        paimonHeight: paimonHeight,
                      ),
                      Visibility(
                        visible: isShootElementalBurst,
                        child: Container(
                          alignment: Alignment(elementalBurstCoordinate[0], elementalBurstCoordinate[1]),
                          child: Image.asset(
                            'lib/assets/images/paimon.png',
                            width: MediaQuery.of(context).size.height * paimonHeight / 2,
                            height: MediaQuery.of(context).size.height * paimonHeight / 2,
                            fit: BoxFit.fill,
                          ),
                        ),
                      ),
                      ...elementEnergies.map((ElementEnergy elementEnergy) => elementEnergyBox(elementEnergy)).toList(),
                    ],
                  ),
                ),
              ),
            ),
            Expanded(
              flex: 8,
              child: Container(
                color: ColorTable.primaryWhiteColor,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    GestureDetector(
                      onTap: shootElementalBurst,
                      child: Container(
                        width: 100,
                        height: 100,
                        color: elementsCount >= 5 ? ColorTable.primaryGreenColor : ColorTable.primaryBlackColor.withOpacity(0.2),
                        child: Center(
                          child: Text(
                            '元素爆発',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: elementsCount >= 5 ? ColorTable.primaryBlackColor : ColorTable.primaryBlackColor.withOpacity(0.2),
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          '元素エネルギー',
                          style: TextStyle(
                            color: ColorTable.primaryBlackColor,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          elementsCount.toString(),
                          style: const TextStyle(
                            color: ColorTable.primaryBlackColor,
                            fontSize: 24,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 元素エネルギー描画用
  Widget elementEnergyBox(ElementEnergy elementEnergy) {
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
            'lib/assets/images/elements/${elementEnergy.elementType}.png',
            width: MediaQuery.of(context).size.width * elementEnergy.width / 2,
            height: MediaQuery.of(context).size.height * 3 / 4 * elementEnergy.height / 3,
            fit: BoxFit.fill,
          ),
        ],
      ),
    );
  }
}
