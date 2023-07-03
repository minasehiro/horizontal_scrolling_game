import 'dart:math';
import 'package:flutter/material.dart';

import '../color_table.dart';
import 'components/character.dart';
import 'components/genshin_element.dart';
import 'components/square.dart';
import 'constants.dart';
import 'helper_methods.dart';

class ElementalStrategy extends StatefulWidget {
  const ElementalStrategy({super.key});

  @override
  State<ElementalStrategy> createState() => _ElementalStrategyState();
}

class _ElementalStrategyState extends State<ElementalStrategy> with SingleTickerProviderStateMixin {
  late List<List<Character?>> field; // フィールド管理用の配列
  Character? selectedCharacter; // 選択されている駒
  int selectedRow = -1; // 選択されている駒の行番号
  int selectedCol = -1; // 選択されている駒の列番号
  List<List<int>> validMoves = []; // 移動可能な座標の配列
  bool isAllyTurn = true; // 味方のターンかどうか
  int turnCount = 1; // 経過ターン
  List<String> history = ["対戦開始！！"]; // ログ
  List<Map<String, dynamic>> elementalParticles = []; // 元素粒子の種類と発生座標
  List<GenshinElement> allyElements = [
    GenshinElement(type: ElementType.anemo, imagePath: "lib/assets/images/elements/anemo.png"),
    GenshinElement(type: ElementType.cryo, imagePath: "lib/assets/images/elements/cryo.png"),
    GenshinElement(type: ElementType.electro, imagePath: "lib/assets/images/elements/electro.png"),
    GenshinElement(type: ElementType.hydro, imagePath: "lib/assets/images/elements/hydro.png"),
  ];
  List<GenshinElement> enemyElements = [
    GenshinElement(type: ElementType.pyro, imagePath: "lib/assets/images/elements/pyro.png"),
    GenshinElement(type: ElementType.anemo, imagePath: "lib/assets/images/elements/anemo.png"),
    GenshinElement(type: ElementType.dendro, imagePath: "lib/assets/images/elements/dendro.png"),
    GenshinElement(type: ElementType.geo, imagePath: "lib/assets/images/elements/geo.png"),
  ];
  bool isLaunchElementalBurst = false; // 元素爆発を発動
  bool isLaunchElementalSkill = false; // 元素スキルを発動
  late AnimationController animationController; // カットイン
  late Animation<Offset> offsetAnimation; // カットイン
  late TweenSequence<Offset> tweenSequence; // カットイン
  late ScrollController scrollController; // 行動履歴

  late List<Character> fieldCharacters; // 選択されたキャラクター一覧
  int currentCharacterIndex = 0; // 行動するキャラクター

  @override
  void initState() {
    super.initState();

    // 敵陣
    fieldCharacters = [
      Character(
        type: CharacterType.kaedeharaKazuha,
        elementType: ElementType.anemo,
        isAlly: true,
        imagePath: "lib/assets/images/elemental_strategy/characters/up_kaedeharaKazuha.png",
        elementEnergy: 0,
        hitPoint: 100,
        currentRow: 5,
        currentCol: 1,
      ),
      Character(
        type: CharacterType.zhongli,
        elementType: ElementType.geo,
        isAlly: false,
        imagePath: "lib/assets/images/elemental_strategy/characters/down_zhongli.png",
        elementEnergy: 0,
        hitPoint: 70,
        currentRow: 0,
        currentCol: 4,
      ),
      Character(
        type: CharacterType.kamisatoAyaka,
        elementType: ElementType.cryo,
        isAlly: true,
        imagePath: "lib/assets/images/elemental_strategy/characters/up_kamisatoAyaka.png",
        elementEnergy: 0,
        hitPoint: 100,
        currentRow: 5,
        currentCol: 2,
      ),
      Character(
        type: CharacterType.nahida,
        elementType: ElementType.dendro,
        isAlly: false,
        imagePath: "lib/assets/images/elemental_strategy/characters/down_nahida.png",
        elementEnergy: 0,
        hitPoint: 45,
        currentRow: 0,
        currentCol: 3,
      ),
      Character(
        type: CharacterType.yaeMiko,
        elementType: ElementType.electro,
        isAlly: true,
        imagePath: "lib/assets/images/elemental_strategy/characters/up_yaeMiko.png",
        elementEnergy: 0,
        hitPoint: 100,
        currentRow: 5,
        currentCol: 3,
      ),
      Character(
        type: CharacterType.xiao,
        elementType: ElementType.anemo,
        isAlly: false,
        imagePath: "lib/assets/images/elemental_strategy/characters/down_xiao.png",
        elementEnergy: 0,
        hitPoint: 100,
        currentRow: 0,
        currentCol: 2,
      ),
      Character(
        type: CharacterType.xingqiu,
        elementType: ElementType.hydro,
        isAlly: true,
        imagePath: "lib/assets/images/elemental_strategy/characters/up_xingqiu.png",
        elementEnergy: 0,
        hitPoint: 100,
        currentRow: 5,
        currentCol: 4,
      ),
      Character(
        type: CharacterType.yanfei,
        elementType: ElementType.pyro,
        isAlly: false,
        imagePath: "lib/assets/images/elemental_strategy/characters/down_yanfei.png",
        elementEnergy: 0,
        hitPoint: 10,
        currentRow: 0,
        currentCol: 1,
      ),
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
          // 元素エネルギーを消費
          double totalEnergy = selectedCharacter!.elementEnergy - 100;

          var newCharacter = Character(
            type: selectedCharacter!.type,
            elementType: selectedCharacter!.elementType,
            isAlly: selectedCharacter!.isAlly,
            imagePath: selectedCharacter!.imagePath,
            elementEnergy: totalEnergy < 0 ? 0 : totalEnergy,
            hitPoint: selectedCharacter!.hitPoint,
            currentRow: selectedCharacter!.currentRow,
            currentCol: selectedCharacter!.currentCol,
          );

          // 付近のキャラにダメージ
          List<List<int>> targetCoordinates = [];

          var directions = [
            [-1, 0], // 上
            [1, 0], // 下
            [0, -1], // 左
            [0, 1], // 右
            [-1, -1], // 左上
            [-1, 1], // 右上
            [1, -1], // 左下
            [1, 1], // 右下
          ];

          for (var direction in directions) {
            var newRow = selectedRow + (direction[0]);
            var newCol = selectedCol + (direction[1]);

            // フィールドから出た場合
            if (!isInField(newRow, newCol)) {
              continue;
            }

            // 対象の座標が空
            if (field[newRow][newCol] == null) {
              continue;
            }

            // 対象の座標が味方のキャラ
            if (field[newRow][newCol] != null && field[newRow][newCol]!.isAlly) {
              continue;
            }

            targetCoordinates.add([newRow, newCol]);
          }

          setState(() {
            // 付近にいたキャラにダメージを与え、フィールドに展開
            for (var targetCoordinate in targetCoordinates) {
              var character = field[targetCoordinate[0]][targetCoordinate[1]];
              var remainingHitPoint = character!.hitPoint - 50;

              var newCharacter = Character(
                type: character.type,
                elementType: character.elementType,
                isAlly: character.isAlly,
                imagePath: character.imagePath,
                elementEnergy: character.elementEnergy,
                hitPoint: remainingHitPoint > 0 ? remainingHitPoint : 100,
                currentRow: character.currentRow,
                currentCol: character.currentCol,
              );

              field[targetCoordinate[0]][targetCoordinate[1]] = newCharacter;

              history.add("${newCharacter.name()}に50ダメージ");
              history.add("${newCharacter.name()}の残りHP${newCharacter.hitPoint}");
              scrollController.animateTo(
                scrollController.position.maxScrollExtent,
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOut,
              );
            }

            // 元素爆発を終了
            isLaunchElementalBurst = false;

            // 元素エネルギーを減らしたキャラをフィールドに展開
            field[selectedRow][selectedCol] = newCharacter;

            // 一番古い元素粒子を消す
            if (elementalParticles.isNotEmpty && elementalParticles.length > 6) {
              elementalParticles.removeAt(0);
            }
            // 新たに元素粒子を生成
            if (elementalParticles.length < 6) {
              elementalParticles.add(buildElementalParticle(allyElements, [1, 2, 3, 4], [0, 1, 2, 3, 4, 5]));
            }
          });
        } else if (isLaunchElementalSkill) {
          // 付近のキャラにダメージ
          List<List<int>> targetCoordinates = [];

          var directions = [
            [-1, 0], // 上
            [1, 0], // 下
            [0, -1], // 左
            [0, 1], // 右
            [-1, -1], // 左上
            [-1, 1], // 右上
            [1, -1], // 左下
            [1, 1], // 右下
          ];

          for (var direction in directions) {
            var newRow = selectedRow + (direction[0]);
            var newCol = selectedCol + (direction[1]);

            // フィールドから出た場合
            if (!isInField(newRow, newCol)) {
              continue;
            }

            // 対象の座標が空
            if (field[newRow][newCol] == null) {
              continue;
            }

            // 対象の座標が味方のキャラ
            if (field[newRow][newCol] != null && field[newRow][newCol]!.isAlly) {
              continue;
            }

            targetCoordinates.add([newRow, newCol]);
          }

          setState(() {
            // 付近にいたキャラにダメージを与え、フィールドに展開
            for (var targetCoordinate in targetCoordinates) {
              var character = field[targetCoordinate[0]][targetCoordinate[1]];
              var remainingHitPoint = character!.hitPoint - 25;

              var newCharacter = Character(
                type: character.type,
                elementType: character.elementType,
                isAlly: character.isAlly,
                imagePath: character.imagePath,
                elementEnergy: character.elementEnergy,
                hitPoint: remainingHitPoint > 0 ? remainingHitPoint : 100,
                currentRow: character.currentRow,
                currentCol: character.currentCol,
              );

              field[targetCoordinate[0]][targetCoordinate[1]] = newCharacter;

              history.add("${newCharacter.name()}に25ダメージ");
              history.add("${newCharacter.name()}の残りHP${newCharacter.hitPoint}");
              scrollController.animateTo(
                scrollController.position.maxScrollExtent,
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOut,
              );
            }

            // 元素スキル処理を終了
            isLaunchElementalSkill = false;

            // 一番古い元素粒子を消す
            if (elementalParticles.isNotEmpty && elementalParticles.length > 6) {
              elementalParticles.removeAt(0);
            }
            // 新たに元素粒子を生成
            if (elementalParticles.length < 6) {
              elementalParticles.add(buildElementalParticle(allyElements, [1, 2, 3, 4], [0, 1, 2, 3, 4, 5]));
            }
          });
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

    scrollController = ScrollController();

    _initializeBoard();

    // 初期行動キャラを選択
    selectedCharacter = fieldCharacters[currentCharacterIndex];
    selectedRow = fieldCharacters[currentCharacterIndex].currentRow;
    selectedCol = fieldCharacters[currentCharacterIndex].currentCol;
    validMoves = calculateRawValidMoves(field, selectedRow, selectedCol, selectedCharacter); // 移動可能な座標を計算
  }

  @override
  void dispose() {
    super.dispose();

    animationController.dispose();
  }

  // 盤面の初期化
  void _initializeBoard() {
    List<List<Character?>> newField = List.generate(6, (index) => List.generate(6, (index) => null));

    // 元素粒子をランダムに発生させる
    // 敵の近くに2つ
    elementalParticles.add(buildElementalParticle(enemyElements, [1], [0, 1, 2]));
    elementalParticles.add(buildElementalParticle(enemyElements, [1], [3, 4, 5]));

    // 味方の近くに2つ
    elementalParticles.add(buildElementalParticle(allyElements, [4], [0, 1, 2]));
    elementalParticles.add(buildElementalParticle(allyElements, [4], [3, 4, 5]));

    // 中心付近に2つ
    elementalParticles.add(buildElementalParticle(enemyElements, [2], [0, 1, 2, 3, 4, 5]));
    elementalParticles.add(buildElementalParticle(allyElements, [3], [0, 1, 2, 3, 4, 5]));

    for (var character in fieldCharacters) {
      newField[character.currentRow][character.currentCol] = character;
    }

    field = newField;
  }

  // CPUへターンを渡す
  void turnChange() {
    if (isAllyTurn) {
      setState(() {
        isAllyTurn = !isAllyTurn;
        turnCount++;

        if (currentCharacterIndex == 7) {
          currentCharacterIndex = 0;
        } else {
          currentCharacterIndex++;
        }

        selectedCharacter = fieldCharacters[currentCharacterIndex];
        selectedRow = selectedCharacter!.currentRow;
        selectedCol = selectedCharacter!.currentCol;
        validMoves = calculateRawValidMoves(field, selectedRow, selectedCol, selectedCharacter); // 移動可能な座標を計算
      });

      // CPU行動
      cpuActionWithCpuAi();
    } else {
      setState(() {
        isAllyTurn = !isAllyTurn;
        turnCount++;

        if (currentCharacterIndex == 7) {
          currentCharacterIndex = 0;
        } else {
          currentCharacterIndex++;
        }

        selectedCharacter = fieldCharacters[currentCharacterIndex];
        selectedRow = fieldCharacters[currentCharacterIndex].currentRow;
        selectedCol = fieldCharacters[currentCharacterIndex].currentCol;
        validMoves = calculateRawValidMoves(field, selectedRow, selectedCol, selectedCharacter); // 移動可能な座標を計算
      });
    }
  }

  // ピースを選択する
  void selectCharacter(int row, int col) {
    setState(() {
      // キャラクターを選択していない状態からキャラクターを選択した時
      if (selectedCharacter == null && field[row][col] != null) {
        if (field[row][col]!.isAlly == isAllyTurn) {
          selectedCharacter = field[row][col];
          selectedRow = row;
          selectedCol = col;
        }
        // キャラクターを選択している状態で自分の他のキャラクターを選択した時
      } else if (field[row][col] != null && field[row][col]!.isAlly == selectedCharacter!.isAlly) {
        selectedCharacter = field[row][col];
        selectedRow = row;
        selectedCol = col;
        // 移動可能な座標を選択した時
      } else if (selectedCharacter != null && validMoves.any((coordinate) => coordinate[0] == row && coordinate[1] == col)) {
        moveCharacter(row, col);
      }

      validMoves = calculateRawValidMoves(field, selectedRow, selectedCol, selectedCharacter); // 移動可能な座標を再計算
    });
  }

  // キャラクターを移動
  void moveCharacter(int newRow, int newCol) async {
    late Map<String, dynamic> toRemove = {};
    Character? newCharacter;
    double totalEnergy = selectedCharacter!.elementEnergy;

    for (var elementalParticle in elementalParticles) {
      if (elementalParticle["coordinates"][0] == newRow && elementalParticle["coordinates"][1] == newCol) {
        totalEnergy = selectedCharacter!.elementEnergy + (selectedCharacter!.elementType == elementalParticle["element"].type ? 50 : 25);

        toRemove = elementalParticle;
      }
    }

    newCharacter = Character(
      type: selectedCharacter!.type,
      elementType: selectedCharacter!.elementType,
      isAlly: selectedCharacter!.isAlly,
      imagePath: selectedCharacter!.imagePath,
      elementEnergy: totalEnergy,
      hitPoint: selectedCharacter!.hitPoint,
      currentRow: newRow,
      currentCol: newCol,
    );

    setState(() {
      // キャラクターを入れ替え、元素エネルギーを取り除く
      if (toRemove != {}) {
        elementalParticles.remove(toRemove);
      }

      field[newRow][newCol] = newCharacter; // 新しい座標へ移動
      fieldCharacters[currentCharacterIndex] = newCharacter!;
      field[selectedRow][selectedCol] = null; //元の座標を初期化

      // 履歴に記録
      var currentLog = "${newCharacter.isAlly ? "自分" : "相手"}の${newCharacter.name()}が移動";
      history.add(currentLog);
      scrollController.animateTo(
        scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });

    // 一番古い元素粒子を消す
    if (elementalParticles.isNotEmpty && elementalParticles.length > 6) {
      elementalParticles.removeAt(0);
    }
    // 新たに元素粒子を生成
    if (elementalParticles.length < 6) {
      elementalParticles.add(buildElementalParticle(allyElements, [1, 2, 3, 4], [0, 1, 2, 3, 4, 5]));
    }

    // ターンチェンジ
    turnChange();
  }

  // 元素スキルの発動
  void launchElementalSkill(character) {
    if (character == null || character.isSkillCoolTime()) {
      return;
    }

    setState(() {
      isLaunchElementalSkill = true;

      history.add("${character.name()}が元素スキル ${character.elementalSkillName()} を発動");
      scrollController.animateTo(
        scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });

    animationController.forward();
  }

  // 元素爆発の発動
  void launchElementalBurst(character) {
    if (character == null || character.elementEnergy < 100) {
      return;
    }

    setState(() {
      isLaunchElementalBurst = true;

      history.add("${character.name()}が元素爆発 ${character.elementalBurstName()} を発動");
      scrollController.animateTo(
        scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });

    animationController.forward();
  }

  // 初期化
  void resetGame() {
    Navigator.pop(context);

    _initializeBoard();

    setState(() {
      turnCount = 1;
      isAllyTurn = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // 行動履歴
              Container(
                width: MediaQuery.of(context).size.width * 0.95,
                height: MediaQuery.of(context).size.width * 0.3,
                margin: const EdgeInsets.only(top: 50),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(3),
                  border: Border.all(color: ColorTable.primaryBlackColor, width: 1.0),
                ),
                child: ListView.builder(
                  controller: scrollController,
                  scrollDirection: Axis.vertical,
                  itemCount: history.length,
                  itemBuilder: (BuildContext context, int i) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(3.0),
                        child: Text(
                          history[i],
                          style: const TextStyle(
                            fontSize: 14,
                            letterSpacing: 1.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              // フィールド
              Expanded(
                child: GridView.builder(
                  itemCount: 6 * 6,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 6),
                  itemBuilder: (context, index) {
                    int row = index ~/ 6;
                    int col = index % 6;
                    bool isSelected = row == selectedRow && col == selectedCol;
                    bool isValidMove = false;
                    GenshinElement? element;

                    // 選択中のキャラクターが移動可能な座標かどうか
                    for (var position in validMoves) {
                      if (position[0] == row && position[1] == col) {
                        isValidMove = true;
                      }
                    }

                    // 元素粒子が発生しているかどうか
                    for (var elementalParticle in elementalParticles) {
                      if (elementalParticle["coordinates"][0] == row && elementalParticle["coordinates"][1] == col) {
                        element = elementalParticle["element"];
                      }
                    }

                    return Square(
                      piece: field[row][col],
                      isSelected: isSelected,
                      isValidMove: isValidMove,
                      onTap: () => selectCharacter(row, col),
                      element: element,
                    );
                  },
                ),
              ),
              // ボタン
              Container(
                padding: const EdgeInsets.all(8.0),
                width: MediaQuery.of(context).size.width * 0.95,
                height: MediaQuery.of(context).size.width * 0.3,
                margin: const EdgeInsets.only(bottom: 50),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    GestureDetector(
                      onTap: () {
                        if (canLaunchElementalSkill(selectedCharacter)) {
                          launchElementalSkill(selectedCharacter);
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: canLaunchElementalSkill(selectedCharacter) ? Colors.red[400] : Colors.grey[300],
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Text(
                          "元素スキル",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        if (canLaunchElementalBurst(selectedCharacter)) {
                          launchElementalBurst(selectedCharacter);
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: canLaunchElementalBurst(selectedCharacter) ? Colors.yellow[400] : Colors.grey[300],
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Text(
                          "元素爆発",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
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
                              selectedCharacter!.elementalBurstName().toString(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ),
                          Text(
                            "~ ${selectedCharacter!.elementalBurstVoice().toString()} ~",
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
                              selectedCharacter!.elementalSkillName().toString(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ),
                          Text(
                            "~ ${selectedCharacter!.elementalSkillVoice().toString()} ~",
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
    );
  }

  // CPUの行動制御
  void cpuActionWithCpuAi() {
    var random = Random();

    // 移動可能な座標からランダムにひとつ選ぶ
    int randomIndex = random.nextInt(validMoves.length);
    List<int> candidateMoves = validMoves[randomIndex];

    // 移動実行
    moveCharacter(candidateMoves[0], candidateMoves[1]);
  }
}
