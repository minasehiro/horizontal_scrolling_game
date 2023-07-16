import 'dart:async';

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

class _GenshinStrileState extends State<GenshinStrile> with SingleTickerProviderStateMixin {
  Character? selectedCharacter; // 選択されている駒
  int turnCount = 1; // 経過ターン
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
  bool isLaunchElementalBurst = false; // 元素爆発を発動
  bool isLaunchElementalSkill = false; // 元素スキルを発動
  late AnimationController animationController; // カットイン
  late Animation<Offset> offsetAnimation; // カットイン
  late TweenSequence<Offset> tweenSequence; // カットイン

  late List<Character> fieldCharacters; // 選択されたキャラクター一覧
  int currentCharacterIndex = 0; // 行動するキャラクター
  List<Map<String, dynamic>> currentDamages = []; // 発生したダメージ

  late Offset dragStartOffset;
  late double dragDistance; // 引っ張った距離
  late Direction xDragDirection;
  late Direction yDragDirection;
  late double xMoveValue = 0; // X軸の移動距離
  late double yMoveValue = 0; // Y軸の移動距離

  @override
  void initState() {
    super.initState();

    fieldCharacters = [
      buildCharacter(CharacterType.nahida, -0.6, 0.7),
      buildCharacter(CharacterType.zhongli, -0.2, 0.7),
      buildCharacter(CharacterType.yaeMiko, 0.2, 0.7),
      buildCharacter(CharacterType.xingqiu, 0.6, 0.7),
    ];

    // 全部で1秒のアニメーション
    // TweenSequenceItem.weight によって分割される
    animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
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

        // ターンチェンジ
        turnChange();
      }
    });

    // 0.1秒で右から中央へ、中央に0.8秒留まり、0.1秒で中央から左へ
    tweenSequence = TweenSequence<Offset>([
      TweenSequenceItem(
        tween: Tween(
          begin: const Offset(1.0, 0.0),
          end: const Offset(0.0, 0.0),
        ),
        weight: 1,
      ),
      TweenSequenceItem(
        tween: Tween(
          begin: const Offset(0.0, 0.0),
          end: const Offset(0.0, 0.0),
        ),
        weight: 8,
      ),
      TweenSequenceItem(
        tween: Tween(
          begin: const Offset(0.0, 0.0),
          end: const Offset(-1.0, 0.0),
        ),
        weight: 1,
      ),
    ]);

    offsetAnimation = animationController.drive(tweenSequence);

    _initializeField();

    // 初期行動キャラを選択
    selectedCharacter = fieldCharacters[currentCharacterIndex];
  }

  @override
  void dispose() {
    super.dispose();

    animationController.dispose();
  }

  // 盤面の初期化
  void _initializeField() {
    // 元素粒子をランダムに発生させる
    for (var i = 0; i < 8; i++) {
      elementalParticles.add(
        buildElementalParticle(i.isEven ? allyElements : enemyElements),
      );
    }
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

  // ドラッグの開始
  void onPanStart(detail) {
    setState(() {
      dragStartOffset = detail.globalPosition;
      dragDistance = 0.0;
    });
  }

  // ドラッグ位置の変更
  void onPanUpdate(detail) {
    setState(() {
      dragDistance += detail.delta.distance;

      if (dragStartOffset.dx < detail.globalPosition.dx) {
        xDragDirection = Direction.left;
      } else {
        xDragDirection = Direction.right;
      }

      if (dragStartOffset.dy < detail.globalPosition.dy) {
        yDragDirection = Direction.up;
      } else {
        yDragDirection = Direction.down;
      }
    });
  }

  // ドラッグの終了
  Future<void> onPanEnd() async {
    double dragDistanceValue = dragDistance;

    Timer.periodic(const Duration(milliseconds: 10), (timer) {
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

        xMoveValue = xDragDirection == Direction.right ? 0.02 : -0.02;
        yMoveValue = yDragDirection == Direction.down ? 0.02 : -0.02;
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
      });

      dragDistanceValue -= 1;

      if (dragDistanceValue <= 0) {
        timer.cancel();

        turnChange();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Container(
          width: MediaQuery.of(context).size.width * 0.9,
          height: MediaQuery.of(context).size.height * 0.9,
          decoration: BoxDecoration(
            color: Colors.blueGrey[200],
            border: Border.all(width: 1.0, color: Colors.black),
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
              ),
              CharacterBall(
                character: fieldCharacters[1],
                fieldCharacters: fieldCharacters,
                currentCharacterIndex: currentCharacterIndex,
                onPanStart: onPanStart,
                onPanUpdate: onPanUpdate,
                onPanEnd: onPanEnd,
              ),
              CharacterBall(
                character: fieldCharacters[2],
                fieldCharacters: fieldCharacters,
                currentCharacterIndex: currentCharacterIndex,
                onPanStart: onPanStart,
                onPanUpdate: onPanUpdate,
                onPanEnd: onPanEnd,
              ),
              CharacterBall(
                character: fieldCharacters[3],
                fieldCharacters: fieldCharacters,
                currentCharacterIndex: currentCharacterIndex,
                onPanStart: onPanStart,
                onPanUpdate: onPanUpdate,
                onPanEnd: onPanEnd,
              ),
              if (selectedCharacter != null && isLaunchElementalBurst)
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
  });

  final Character character;
  final List<Character> fieldCharacters;
  final int currentCharacterIndex;
  final Function onPanStart;
  final Function onPanUpdate;
  final Function onPanEnd;

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
            onPanEnd();
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
          ],
        ),
      ),
    );
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
        width: 20.0,
      ),
    );
  }
}
