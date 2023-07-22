import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import '../color_table.dart';
import './components/character.dart';
import './components/element_particle.dart';
import '../constants.dart';
import './helper_methods.dart';

class GenshinStrile extends StatefulWidget {
  const GenshinStrile({super.key});

  @override
  State<GenshinStrile> createState() => _GenshinStrileState();
}

class _GenshinStrileState extends State<GenshinStrile> with TickerProviderStateMixin {
  Character? selectedCharacter; // 選択されている駒
  int turnCount = 1; // 経過ターン
  int speedClearTurn = 20; // スピードクリアと見なされるターン
  double maxTeamHitPoint = 0; // チームHP
  double currentTeamHitPoint = 0; // 現在のチームHP
  List<Map<String, dynamic>> elementalParticles = []; // 元素粒子の種類と発生座標
  List<ElementParticle> allyElements = [
    ElementParticle(type: ElementType.anemo, imagePath: "lib/assets/images/genshin/elements/anemo.png", color: ColorTable.anemoColor),
    ElementParticle(type: ElementType.cryo, imagePath: "lib/assets/images/genshin/elements/cryo.png", color: ColorTable.cryoColor),
    ElementParticle(type: ElementType.electro, imagePath: "lib/assets/images/genshin/elements/electro.png", color: ColorTable.electroColor),
    ElementParticle(type: ElementType.hydro, imagePath: "lib/assets/images/genshin/elements/hydro.png", color: ColorTable.hydroColor),
  ];
  List<ElementParticle> enemyElements = [
    ElementParticle(type: ElementType.pyro, imagePath: "lib/assets/images/genshin/elements/pyro.png", color: ColorTable.pyroColor),
    ElementParticle(type: ElementType.anemo, imagePath: "lib/assets/images/genshin/elements/anemo.png", color: ColorTable.anemoColor),
    ElementParticle(type: ElementType.dendro, imagePath: "lib/assets/images/genshin/elements/dendro.png", color: ColorTable.dendroColor),
    ElementParticle(type: ElementType.geo, imagePath: "lib/assets/images/genshin/elements/geo.png", color: ColorTable.geoColor),
  ];
  bool waitingElementalBurst = false; // 元素爆発 発動待ち状態
  bool isLaunchElementalBurst = false; // 元素爆発を発動
  bool isLaunchElementalSkill = false; // 元素スキルを発動
  late AnimationController animationController; // カットイン
  late Animation<Offset> offsetAnimation; // カットイン
  late TweenSequence<Offset> tweenSequence; // カットイン
  late AnimationController flashingAnimationController; // 点滅アニメーションコントローラー
  late DecorationTween flashingDecorationTween; // 点滅アニメーション

  late List<Character> fieldCharacters; // 選択されたキャラクター一覧
  int currentCharacterIndex = 0; // 行動するキャラクター
  List<Map<String, dynamic>> currentDamages = []; // 発生したダメージ

  double baseMoveValue = 0.1; // 基本の移動距離
  int gameSpeedMilliseconds = 10; // ゲームスピード
  late Offset dragStartOffset;
  late Offset dragOffset = const Offset(0, 0); // ドラッグ位置
  late Direction xDragDirection;
  late Direction yDragDirection;

  @override
  void initState() {
    super.initState();

    fieldCharacters = [
      buildCharacter(CharacterType.kaedeharaKazuha, -0.6, 0.8),
      buildCharacter(CharacterType.zhongli, -0.2, 0.8),
      buildCharacter(CharacterType.yaeMiko, 0.2, 0.8),
      buildCharacter(CharacterType.kamisatoAyaka, 0.6, 0.8),
    ];

    // 合計HPを計算
    for (var character in fieldCharacters) {
      maxTeamHitPoint += character.hitPoint;
    }
    currentTeamHitPoint = maxTeamHitPoint;

    // 初期行動キャラを選択
    selectedCharacter = fieldCharacters[currentCharacterIndex];

    // 元素粒子をランダムに8個発生させる
    for (var i = 0; i < 8; i++) {
      elementalParticles.add(
        buildElementalParticle(i.isEven ? allyElements : enemyElements),
      );
    }

    // 全部で1秒のアニメーション
    // TweenSequenceItem.weight によって分割される
    animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    // アニメーション終了時に発火
    animationController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        // 繰り返し実行できるようにアニメーション終了後にリセット
        animationController.reset();

        if (isLaunchElementalBurst) {
          isLaunchElementalBurst = false;
        } else if (isLaunchElementalSkill) {
          isLaunchElementalSkill = false;
        }

        waitingElementalBurst = false;
      }
    });

    // 0.1秒で右から中央へ、中央に0.8秒留まり、0.1秒で中央から左へ
    tweenSequence = TweenSequence<Offset>([
      TweenSequenceItem(
        tween: Tween(
          begin: const Offset(1.0, 0.0),
          end: const Offset(0.0, 0.0),
        ),
        weight: 2,
      ),
      TweenSequenceItem(
        tween: Tween(
          begin: const Offset(0.0, 0.0),
          end: const Offset(0.0, 0.0),
        ),
        weight: 6,
      ),
      TweenSequenceItem(
        tween: Tween(
          begin: const Offset(0.0, 0.0),
          end: const Offset(-1.0, 0.0),
        ),
        weight: 2,
      ),
    ]);

    offsetAnimation = animationController.drive(tweenSequence);

    flashingAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    flashingDecorationTween = DecorationTween(
      begin: const BoxDecoration(
        color: Colors.white,
      ),
      end: const BoxDecoration(
        color: Colors.black,
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();

    animationController.dispose();
    flashingAnimationController.dispose();
  }

  // 次のキャラクターにターンを渡す
  void turnChange() {
    setState(() {
      Future.delayed(const Duration(seconds: 1), () {
        setState(() {
          currentDamages.clear();
        });
      });

      turnCount++;
      speedClearTurn--;

      if (currentCharacterIndex >= (fieldCharacters.length - 1)) {
        currentCharacterIndex = 0;
      } else {
        currentCharacterIndex++;
      }

      selectedCharacter = fieldCharacters[currentCharacterIndex];
    });
  }

  // 元素スキルの発動
  void launchElementalSkill(character) {
    setState(() {
      isLaunchElementalSkill = true;
    });

    animationController.forward();
  }

  // 元素爆発の発動
  void launchElementalBurst(character) {
    setState(() {
      isLaunchElementalBurst = true;
    });

    animationController.forward();
  }

  // 元素爆発 発動切り替え
  void toggleWaitingElementalBurst() {
    setState(() {
      waitingElementalBurst = !waitingElementalBurst;
    });
  }

  // ドラッグの開始
  void onPanStart(details) {
    setState(() {
      dragStartOffset = details.localPosition;
    });
  }

  // ドラッグ位置の変更
  void onPanUpdate(details) {
    setState(() {
      dragOffset += details.delta;

      if (dragStartOffset.dx < details.localPosition.dx) {
        xDragDirection = Direction.left;
      } else {
        xDragDirection = Direction.right;
      }

      if (dragStartOffset.dy < details.localPosition.dy) {
        yDragDirection = Direction.up;
      } else {
        yDragDirection = Direction.down;
      }
    });
  }

  // ドラッグの終了
  void onPanEnd(character) {
    // 元素爆発発動待ち状態なら発動
    if (waitingElementalBurst) {
      // 点滅アニメーションを止める
      flashingAnimationController.reset();

      launchElementalBurst(character);
    }

    // ひっぱり強度
    double xDiff = (dragStartOffset.dx.abs() - dragOffset.dx.abs()).abs();
    double yDiff = (dragStartOffset.dy.abs() - dragOffset.dy.abs()).abs();
    double pulledDistance = xDiff + yDiff;

    // 目標座標
    double reverseXPositionAbs = dragOffset.dx.abs();
    double reverseYPositionAbs = dragOffset.dy.abs();

    // 移動距離
    late double xMoveValue = 0.1;
    late double yMoveValue = 0.1;

    // 簡易摩擦係数
    late double friction;

    // 摩擦
    // 動摩擦力：F’=μ’N （動摩擦係数: μ’ × 垂直抗力: N）
    // 摩擦係数は素材によって
    // 垂直抗力は質量によって

    // 初速を設定
    while (reverseXPositionAbs > baseMoveValue || reverseYPositionAbs > baseMoveValue) {
      reverseXPositionAbs = reverseXPositionAbs / 2;
      reverseYPositionAbs = reverseYPositionAbs / 2;
    }

    // ひっぱり強度によって摩擦係数を調整
    if (pulledDistance > 200) {
      friction = 0.99;
    } else if (pulledDistance > 100) {
      friction = 0.90;
    } else if (pulledDistance > 80) {
      friction = 0.85;
    } else if (pulledDistance > 50) {
      friction = 0.75;
    } else {
      friction = 0.70;
    }

    int timerIndex = 1;

    Timer.periodic(Duration(milliseconds: gameSpeedMilliseconds), (timer) {
      if (!waitingElementalBurst) {
        setState(() {
          if (selectedCharacter!.currentRow + xMoveValue < -1) {
            xDragDirection = Direction.right;
          } else if (selectedCharacter!.currentRow + xMoveValue > 1) {
            xDragDirection = Direction.left;
          } else if (selectedCharacter!.currentCol + yMoveValue < -1) {
            yDragDirection = Direction.down;
          } else if (selectedCharacter!.currentCol + yMoveValue > 1) {
            yDragDirection = Direction.up;
          }

          // 初速 × 摩擦（0.98のTimerループ数乗） × 壁にぶつかっていた場合は正負切り替え
          xMoveValue = reverseXPositionAbs * math.pow(friction, timerIndex) * (xDragDirection == Direction.right ? 1 : -1);
          yMoveValue = reverseYPositionAbs * math.pow(friction, timerIndex) * (yDragDirection == Direction.down ? 1 : -1);
        });

        setState(() {
          fieldCharacters[currentCharacterIndex] = Character(
            type: selectedCharacter!.type,
            elementType: selectedCharacter!.elementType,
            isAlly: selectedCharacter!.isAlly,
            imagePath: selectedCharacter!.imagePath,
            elementEnergy: selectedCharacter!.elementEnergy,
            hitPoint: selectedCharacter!.hitPoint,
            currentRow: selectedCharacter!.currentRow + xMoveValue,
            currentCol: selectedCharacter!.currentCol + yMoveValue,
            skill: selectedCharacter!.skill,
            lastTriggeredSkill: selectedCharacter!.lastTriggeredSkill,
            burst: selectedCharacter!.burst,
            lastTriggeredBurst: selectedCharacter!.lastTriggeredBurst,
          );

          selectedCharacter = fieldCharacters[currentCharacterIndex];

          dragOffset = const Offset(0, 0);
        });

        if (pulledDistance > 200) {
          pulledDistance -= 0.5;
        } else {
          pulledDistance -= 1.0;
        }

        timerIndex++;

        if (pulledDistance <= 0 || xMoveValue.abs() < 0.0003 || yMoveValue.abs() < 0.0003) {
          timer.cancel();

          turnChange();
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Center(
            child: Container(
              width: MediaQuery.of(context).size.width * 0.9,
              height: MediaQuery.of(context).size.height * 0.7,
              decoration: BoxDecoration(
                color: Colors.blueGrey[200],
              ),
              child: Stack(
                children: [
                  ElementalParticle(elementalParticle: elementalParticles[0]),
                  ElementalParticle(elementalParticle: elementalParticles[1]),
                  ElementalParticle(elementalParticle: elementalParticles[2]),
                  ElementalParticle(elementalParticle: elementalParticles[3]),
                  ElementalParticle(elementalParticle: elementalParticles[4]),
                  ElementalParticle(elementalParticle: elementalParticles[5]),
                  ElementalParticle(elementalParticle: elementalParticles[6]),
                  ElementalParticle(elementalParticle: elementalParticles[7]),
                  CharacterBall(
                    character: fieldCharacters[0],
                    fieldCharacters: fieldCharacters,
                    currentCharacterIndex: currentCharacterIndex,
                    onPanStart: onPanStart,
                    onPanUpdate: onPanUpdate,
                    onPanEnd: onPanEnd,
                    dragOffset: dragOffset,
                  ),
                  CharacterBall(
                    character: fieldCharacters[1],
                    fieldCharacters: fieldCharacters,
                    currentCharacterIndex: currentCharacterIndex,
                    onPanStart: onPanStart,
                    onPanUpdate: onPanUpdate,
                    onPanEnd: onPanEnd,
                    dragOffset: dragOffset,
                  ),
                  CharacterBall(
                    character: fieldCharacters[2],
                    fieldCharacters: fieldCharacters,
                    currentCharacterIndex: currentCharacterIndex,
                    onPanStart: onPanStart,
                    onPanUpdate: onPanUpdate,
                    onPanEnd: onPanEnd,
                    dragOffset: dragOffset,
                  ),
                  CharacterBall(
                    character: fieldCharacters[3],
                    fieldCharacters: fieldCharacters,
                    currentCharacterIndex: currentCharacterIndex,
                    onPanStart: onPanStart,
                    onPanUpdate: onPanUpdate,
                    onPanEnd: onPanEnd,
                    dragOffset: dragOffset,
                  ),
                  if (selectedCharacter != null && isLaunchElementalBurst)
                    Center(
                      child: SlideTransition(
                        position: offsetAnimation,
                        child: Container(
                          width: MediaQuery.of(context).size.width,
                          height: MediaQuery.of(context).size.height * 0.5,
                          padding: const EdgeInsets.symmetric(vertical: 5.0),
                          decoration: BoxDecoration(color: Colors.black.withOpacity(0.8)),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Image.asset(selectedCharacter!.imagePath),
                              Padding(
                                padding: const EdgeInsets.all(5.0),
                                child: Text(
                                  selectedCharacter!.burst.name,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                              Text(
                                "~ ${selectedCharacter!.burst.voice} ~",
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  if (selectedCharacter != null && isLaunchElementalSkill)
                    Center(
                      child: SlideTransition(
                        position: offsetAnimation,
                        child: Container(
                          width: MediaQuery.of(context).size.width,
                          height: 80,
                          padding: const EdgeInsets.symmetric(vertical: 5.0),
                          decoration: BoxDecoration(color: Colors.black.withOpacity(0.9)),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Image.asset(selectedCharacter!.imagePath),
                              Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(5.0),
                                    child: Text(
                                      selectedCharacter!.skill.name,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ),
                                  Text(
                                    "~ ${selectedCharacter!.skill.voice} ~",
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 10,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.only(bottom: 30),
            color: Colors.amberAccent[400],
            child: Column(
              children: [
                SizedBox(
                  width: MediaQuery.of(context).size.width,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: MediaQuery.of(context).size.width * 0.8,
                        padding: const EdgeInsets.only(left: 20.0),
                        child: Column(
                          children: [
                            Stack(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 5.0),
                                  child: Row(
                                    children: [
                                      Container(
                                        height: 15,
                                        color: Colors.black,
                                        padding: const EdgeInsets.symmetric(horizontal: 5.0),
                                        child: const Center(
                                          child: Text(
                                            "HP",
                                            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.greenAccent),
                                          ),
                                        ),
                                      ),
                                      Container(
                                        height: 15,
                                        padding: const EdgeInsets.only(right: 5.0),
                                        decoration: const BoxDecoration(
                                          color: Colors.black,
                                        ),
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Container(
                                              width: (MediaQuery.of(context).size.width * 0.6) * double.parse((currentTeamHitPoint / maxTeamHitPoint).toStringAsFixed(2)),
                                              height: 10,
                                              decoration: BoxDecoration(
                                                color: double.parse((currentTeamHitPoint / maxTeamHitPoint).toStringAsFixed(2)) <= 0.25 ? Colors.red : Colors.lightGreenAccent,
                                                borderRadius: BorderRadius.circular(25),
                                              ),
                                            ),
                                            Container(
                                              width: (MediaQuery.of(context).size.width * 0.6) * (1 - double.parse((currentTeamHitPoint / maxTeamHitPoint).toStringAsFixed(2))),
                                              height: 10,
                                              decoration: BoxDecoration(
                                                color: Colors.transparent,
                                                borderRadius: BorderRadius.circular(25),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.only(top: 7.0, right: 30.0),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      Text(
                                        currentTeamHitPoint.round().toString(),
                                        style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                          shadows: [
                                            Shadow(
                                              offset: Offset(-1.1, -1.1),
                                              color: Colors.black38,
                                            ),
                                            Shadow(
                                              offset: Offset(1.1, -1.1),
                                              color: Colors.black38,
                                            ),
                                            Shadow(
                                              offset: Offset(1.1, 1.1),
                                              color: Colors.black38,
                                            ),
                                            Shadow(
                                              offset: Offset(-1.1, 1.1),
                                              color: Colors.black38,
                                            ),
                                          ],
                                        ),
                                      ),
                                      const Text(
                                        "  /  ",
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                          shadows: [
                                            Shadow(
                                              offset: Offset(-1.1, -1.1),
                                              color: Colors.black38,
                                            ),
                                            Shadow(
                                              offset: Offset(1.1, -1.1),
                                              color: Colors.black38,
                                            ),
                                            Shadow(
                                              offset: Offset(1.1, 1.1),
                                              color: Colors.black38,
                                            ),
                                            Shadow(
                                              offset: Offset(-1.1, 1.1),
                                              color: Colors.black38,
                                            ),
                                          ],
                                        ),
                                      ),
                                      Text(
                                        maxTeamHitPoint.round().toString(),
                                        style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                          shadows: [
                                            Shadow(
                                              offset: Offset(-1.1, -1.1),
                                              color: Colors.black38,
                                            ),
                                            Shadow(
                                              offset: Offset(1.1, -1.1),
                                              color: Colors.black38,
                                            ),
                                            Shadow(
                                              offset: Offset(1.1, 1.1),
                                              color: Colors.black38,
                                            ),
                                            Shadow(
                                              offset: Offset(-1.1, 1.1),
                                              color: Colors.black38,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                CharacterPanel(
                                  character: fieldCharacters[0],
                                  actionableCharacter: fieldCharacters[currentCharacterIndex],
                                  onTap: toggleWaitingElementalBurst,
                                  waitingElementalBurst: waitingElementalBurst,
                                  animationController: flashingAnimationController,
                                  decorationTween: flashingDecorationTween,
                                ),
                                CharacterPanel(
                                  character: fieldCharacters[1],
                                  actionableCharacter: fieldCharacters[currentCharacterIndex],
                                  onTap: toggleWaitingElementalBurst,
                                  waitingElementalBurst: waitingElementalBurst,
                                  animationController: flashingAnimationController,
                                  decorationTween: flashingDecorationTween,
                                ),
                                CharacterPanel(
                                  character: fieldCharacters[2],
                                  actionableCharacter: fieldCharacters[currentCharacterIndex],
                                  onTap: toggleWaitingElementalBurst,
                                  waitingElementalBurst: waitingElementalBurst,
                                  animationController: flashingAnimationController,
                                  decorationTween: flashingDecorationTween,
                                ),
                                CharacterPanel(
                                  character: fieldCharacters[3],
                                  actionableCharacter: fieldCharacters[currentCharacterIndex],
                                  onTap: toggleWaitingElementalBurst,
                                  waitingElementalBurst: waitingElementalBurst,
                                  animationController: flashingAnimationController,
                                  decorationTween: flashingDecorationTween,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        width: MediaQuery.of(context).size.width * 0.2,
                        child: Column(
                          children: [
                            Container(
                              color: Colors.indigo[900],
                              padding: const EdgeInsets.symmetric(vertical: 5.0),
                              margin: const EdgeInsets.only(top: 5.0, right: 5.0, bottom: 5.0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                children: [
                                  const Text(
                                    "スピード\nクリア",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 10.0,
                                      fontWeight: FontWeight.bold,
                                      height: 1.0,
                                      color: Colors.cyanAccent,
                                      shadows: [
                                        Shadow(
                                          offset: Offset(-1.1, -1.1),
                                          color: Colors.black26,
                                        ),
                                        Shadow(
                                          offset: Offset(1.1, -1.1),
                                          color: Colors.black26,
                                        ),
                                        Shadow(
                                          offset: Offset(1.1, 1.1),
                                          color: Colors.white24,
                                        ),
                                        Shadow(
                                          offset: Offset(-1.1, 1.1),
                                          color: Colors.white24,
                                        ),
                                      ],
                                    ),
                                  ),
                                  Text(
                                    speedClearTurn.toString(),
                                    style: const TextStyle(
                                      fontSize: 18.0,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                      shadows: [
                                        Shadow(
                                          offset: Offset(-1.1, -1.1),
                                          color: Colors.black38,
                                        ),
                                        Shadow(
                                          offset: Offset(1.1, -1.1),
                                          color: Colors.black38,
                                        ),
                                        Shadow(
                                          offset: Offset(1.1, 1.1),
                                          color: Colors.black38,
                                        ),
                                        Shadow(
                                          offset: Offset(-1.1, 1.1),
                                          color: Colors.black38,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              decoration: BoxDecoration(
                                border: Border.all(width: 3.0, color: Colors.grey),
                                color: Colors.grey[800],
                              ),
                              child: Image.asset(
                                "lib/assets/images/genshin/characters/paimon.png",
                                width: MediaQuery.of(context).size.width * 0.12,
                                height: MediaQuery.of(context).size.width * 0.12,
                              ),
                            )
                          ],
                        ),
                      )
                    ],
                  ),
                ),
                Container(
                  width: MediaQuery.of(context).size.width,
                  padding: const EdgeInsets.symmetric(vertical: 5.0),
                  child: Row(
                    children: [
                      Container(
                        width: MediaQuery.of(context).size.width * 0.8,
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          children: [
                            Container(
                              color: Colors.brown[400],
                              margin: const EdgeInsets.symmetric(horizontal: 3.0),
                              padding: const EdgeInsets.symmetric(horizontal: 5.0),
                              child: Column(
                                children: [
                                  const Text(
                                    "TURN",
                                    style: TextStyle(
                                      fontSize: 10.0,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                      shadows: [
                                        Shadow(
                                          offset: Offset(-1.1, -1.1),
                                          color: Colors.black38,
                                        ),
                                        Shadow(
                                          offset: Offset(1.1, -1.1),
                                          color: Colors.black38,
                                        ),
                                        Shadow(
                                          offset: Offset(1.1, 1.1),
                                          color: Colors.black38,
                                        ),
                                        Shadow(
                                          offset: Offset(-1.1, 1.1),
                                          color: Colors.black38,
                                        ),
                                      ],
                                    ),
                                  ),
                                  Text(
                                    turnCount.toString(),
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 16.0,
                                      fontWeight: FontWeight.bold,
                                      shadows: [
                                        Shadow(
                                          offset: Offset(-1.1, -1.1),
                                          color: Colors.black38,
                                        ),
                                        Shadow(
                                          offset: Offset(1.1, -1.1),
                                          color: Colors.black38,
                                        ),
                                        Shadow(
                                          offset: Offset(1.1, 1.1),
                                          color: Colors.black38,
                                        ),
                                        Shadow(
                                          offset: Offset(-1.1, 1.1),
                                          color: Colors.black38,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              color: Colors.brown[400],
                              margin: const EdgeInsets.symmetric(horizontal: 3.0),
                              padding: const EdgeInsets.only(right: 60.0),
                              child: const Row(
                                children: [
                                  Icon(
                                    Icons.monetization_on,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                  SizedBox(
                                    width: 3.0,
                                    height: 3.0,
                                  ),
                                  Text(
                                    "0",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                      fontSize: 16.0,
                                      shadows: [
                                        Shadow(
                                          offset: Offset(-1.1, -1.1),
                                          color: Colors.black38,
                                        ),
                                        Shadow(
                                          offset: Offset(1.1, -1.1),
                                          color: Colors.black38,
                                        ),
                                        Shadow(
                                          offset: Offset(1.1, 1.1),
                                          color: Colors.black38,
                                        ),
                                        Shadow(
                                          offset: Offset(-1.1, 1.1),
                                          color: Colors.black38,
                                        ),
                                      ],
                                    ),
                                  )
                                ],
                              ),
                            ),
                            Container(
                              color: Colors.brown[400],
                              margin: const EdgeInsets.symmetric(horizontal: 3.0),
                              padding: const EdgeInsets.only(right: 5.0),
                              child: const Row(
                                children: [
                                  Icon(
                                    Icons.diamond,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                  SizedBox(
                                    width: 3.0,
                                    height: 3.0,
                                  ),
                                  Text(
                                    "0",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                      fontSize: 16.0,
                                      shadows: [
                                        Shadow(
                                          offset: Offset(-1.1, -1.1),
                                          color: Colors.black38,
                                        ),
                                        Shadow(
                                          offset: Offset(1.1, -1.1),
                                          color: Colors.black38,
                                        ),
                                        Shadow(
                                          offset: Offset(1.1, 1.1),
                                          color: Colors.black38,
                                        ),
                                        Shadow(
                                          offset: Offset(-1.1, 1.1),
                                          color: Colors.black38,
                                        ),
                                      ],
                                    ),
                                  )
                                ],
                              ),
                            ),
                            Container(
                              color: Colors.brown[400],
                              margin: const EdgeInsets.symmetric(horizontal: 3.0),
                              padding: const EdgeInsets.only(right: 5.0),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.egg,
                                    color: Colors.yellow[600],
                                    size: 20,
                                  ),
                                  const SizedBox(
                                    width: 3.0,
                                    height: 3.0,
                                  ),
                                  const Text(
                                    "0",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                      fontSize: 16.0,
                                      shadows: [
                                        Shadow(
                                          offset: Offset(-1.1, -1.1),
                                          color: Colors.black38,
                                        ),
                                        Shadow(
                                          offset: Offset(1.1, -1.1),
                                          color: Colors.black38,
                                        ),
                                        Shadow(
                                          offset: Offset(1.1, 1.1),
                                          color: Colors.black38,
                                        ),
                                        Shadow(
                                          offset: Offset(-1.1, 1.1),
                                          color: Colors.black38,
                                        ),
                                      ],
                                    ),
                                  )
                                ],
                              ),
                            ),
                            Container(
                              color: Colors.brown[400],
                              margin: const EdgeInsets.symmetric(horizontal: 3.0),
                              padding: const EdgeInsets.only(right: 5.0),
                              child: const Row(
                                children: [
                                  Icon(
                                    Icons.egg,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                  SizedBox(
                                    width: 3.0,
                                    height: 3.0,
                                  ),
                                  Text(
                                    "0",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                      fontSize: 16.0,
                                      shadows: [
                                        Shadow(
                                          offset: Offset(-1.1, -1.1),
                                          color: Colors.black38,
                                        ),
                                        Shadow(
                                          offset: Offset(1.1, -1.1),
                                          color: Colors.black38,
                                        ),
                                        Shadow(
                                          offset: Offset(1.1, 1.1),
                                          color: Colors.black38,
                                        ),
                                        Shadow(
                                          offset: Offset(-1.1, 1.1),
                                          color: Colors.black38,
                                        ),
                                      ],
                                    ),
                                  )
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        width: MediaQuery.of(context).size.width * 0.2,
                        padding: const EdgeInsets.symmetric(vertical: 5.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(3.0),
                              decoration: const BoxDecoration(
                                color: Colors.teal,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.priority_high,
                                color: Colors.white,
                              ),
                            ),
                            Container(
                              color: Colors.blue[800],
                              padding: const EdgeInsets.all(3.0),
                              child: const Icon(
                                Icons.menu,
                                color: Colors.white,
                              ),
                            )
                          ],
                        ),
                      )
                    ],
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class CharacterPanel extends StatelessWidget {
  const CharacterPanel({
    super.key,
    required this.character,
    required this.actionableCharacter,
    required this.onTap,
    required this.waitingElementalBurst,
    required this.animationController,
    required this.decorationTween,
  });

  final Character character;
  final Character actionableCharacter;
  final Function onTap;
  final bool waitingElementalBurst;
  final AnimationController animationController;
  final DecorationTween decorationTween;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (character.type == actionableCharacter.type && !waitingElementalBurst) {
          animationController.repeat(reverse: true);
        } else {
          animationController.reset();
        }

        if (character.type == actionableCharacter.type) {
          onTap();
        }
      },
      child: DecoratedBoxTransition(
        decoration: decorationTween.animate(animationController),
        child: Container(
          margin: const EdgeInsets.all(3.0),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(5),
            color: elementColor(character.elementType),
          ),
          child: Image.asset(
            character.imagePath,
            width: 60,
          ),
        ),
      ),
    );
  }
}

class CharacterBall extends StatelessWidget {
  const CharacterBall({
    super.key,
    required this.character,
    required this.fieldCharacters,
    required this.currentCharacterIndex,
    required this.onPanStart,
    required this.onPanUpdate,
    required this.onPanEnd,
    required this.dragOffset,
  });

  final Character character;
  final List<Character> fieldCharacters;
  final int currentCharacterIndex;
  final Function onPanStart;
  final Function onPanUpdate;
  final Function onPanEnd;
  final Offset dragOffset;

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment(character.currentRow, character.currentCol),
      child: GestureDetector(
        // ドラッグの開始
        onPanStart: (details) {
          if (fieldCharacters[currentCharacterIndex].type == character.type) {
            onPanStart(details);
          }
        },
        // ドラッグ位置の変化
        onPanUpdate: (details) {
          if (fieldCharacters[currentCharacterIndex].type == character.type) {
            onPanUpdate(details);
          }
        },
        // ドラッグの終了
        onPanEnd: (details) {
          if (fieldCharacters[currentCharacterIndex].type == character.type) {
            onPanEnd(character);
          }
        },
        child: Stack(
          children: [
            SizedBox(
              width: 50,
              child: Image.asset(
                character.imagePath,
              ),
            ),
            if (fieldCharacters[currentCharacterIndex].type == character.type)
              CustomPaint(
                painter: DrawArrow(
                  centerRow: -0.6,
                  centerCol: 0.8,
                  dragOffset: dragOffset,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class DrawArrow extends CustomPainter {
  DrawArrow({
    required this.centerRow,
    required this.centerCol,
    required this.dragOffset,
  });

  final double centerRow;
  final double centerCol;
  final Offset dragOffset;

  final _paint = Paint()
    ..color = Colors.black
    ..strokeWidth = 2;

  @override
  void paint(Canvas canvas, Size size) {
    if (dragOffset.dx.abs() > 0 || dragOffset.dy.abs() > 0) {
      final p1 = Offset(dragOffset.dx + 25, dragOffset.dy + 25);
      final p2 = Offset((dragOffset.dx * -1) + 25, (dragOffset.dy * -1) + 25);

      canvas.drawLine(p1, p2, _paint);

      final dX = p2.dx - p1.dx;
      final dY = p2.dy - p1.dy;
      final angle = math.atan2(dY, dX);
      const arrowSize = 15;
      const arrowAngle = 25 * math.pi / 180;

      final path = Path();

      path.moveTo(p2.dx - arrowSize * math.cos(angle - arrowAngle), p2.dy - arrowSize * math.sin(angle - arrowAngle));
      path.lineTo(p2.dx, p2.dy);
      path.lineTo(p2.dx - arrowSize * math.cos(angle + arrowAngle), p2.dy - arrowSize * math.sin(angle + arrowAngle));
      path.close();
      canvas.drawPath(path, _paint);
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}

class ElementalParticle extends StatelessWidget {
  const ElementalParticle({
    super.key,
    required this.elementalParticle,
  });

  final Map<String, dynamic> elementalParticle;

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment(elementalParticle["coordinates"][0], elementalParticle["coordinates"][1]),
      child: Image.asset(
        elementalParticle["element"].imagePath,
        width: 30.0,
      ),
    );
  }
}
