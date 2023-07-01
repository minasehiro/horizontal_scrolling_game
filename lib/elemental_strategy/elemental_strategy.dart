import 'dart:math';
import 'package:flutter/material.dart';
import 'package:horizontal_scrolling_game/elemental_strategy/components/genshin_element.dart';

import '../color_table.dart';
import 'components/character.dart';
import 'components/square.dart';
import 'constants.dart';
import 'helper_methods.dart';
import 'cpu_ai.dart';

class ElementalStrategy extends StatefulWidget {
  const ElementalStrategy({super.key});

  @override
  State<ElementalStrategy> createState() => _ElementalStrategyState();
}

class _ElementalStrategyState extends State<ElementalStrategy> {
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
    GenshinElement(type: ElementType.pyro, imagePath: "lib/assets/images/elements/pyro.png"),
  ];
  List<GenshinElement> enemyElements = [
    GenshinElement(type: ElementType.anemo, imagePath: "lib/assets/images/elements/anemo.png"),
    GenshinElement(type: ElementType.pyro, imagePath: "lib/assets/images/elements/pyro.png"),
  ];

  @override
  void initState() {
    super.initState();

    _initializeBoard();
  }

  // 盤面の初期化
  void _initializeBoard() {
    List<List<Character?>> newField = List.generate(8, (index) => List.generate(8, (index) => null));

    // 元素粒子をランダムに発生させる
    // 敵の近くに2つ
    elementalParticles.add(buildElementalParticle(enemyElements, [1], [1, 2, 3, 4, 5, 6]));
    elementalParticles.add(buildElementalParticle(enemyElements, [1], [1, 2, 3, 4, 5, 6]));

    // 味方の近くに2つ
    elementalParticles.add(buildElementalParticle(allyElements, [6], [1, 2, 3, 4, 5, 6]));
    elementalParticles.add(buildElementalParticle(allyElements, [6], [1, 2, 3, 4, 5, 6]));

    // 中心付近に4つ
    elementalParticles.add(buildElementalParticle(enemyElements, [2, 3], [0, 1, 2, 3, 4, 5, 6, 7]));
    elementalParticles.add(buildElementalParticle(enemyElements, [4, 5], [0, 1, 2, 3, 4, 5, 6, 7]));
    elementalParticles.add(buildElementalParticle(allyElements, [2, 3], [0, 1, 2, 3, 4, 5, 6, 7]));
    elementalParticles.add(buildElementalParticle(allyElements, [4, 5], [0, 1, 2, 3, 4, 5, 6, 7]));

    for (int i = 0; i < 8; i++) {
      // 敵陣
      newField[0][2] = Character(
        type: CharacterType.yanfei,
        elementType: ElementType.pyro,
        isAlly: false,
        imagePath: "lib/assets/images/elemental_strategy/characters/down_yanfei.png",
        elementEnergy: 0,
      );
      newField[0][3] = Character(
        type: CharacterType.xiao,
        elementType: ElementType.anemo,
        isAlly: false,
        imagePath: "lib/assets/images/elemental_strategy/characters/down_xiao.png",
        elementEnergy: 0,
      );
      newField[0][4] = Character(
        type: CharacterType.venti,
        elementType: ElementType.anemo,
        isAlly: false,
        imagePath: "lib/assets/images/elemental_strategy/characters/down_venti.png",
        elementEnergy: 0,
      );
      newField[0][5] = Character(
        type: CharacterType.kazuha,
        elementType: ElementType.anemo,
        isAlly: false,
        imagePath: "lib/assets/images/elemental_strategy/characters/down_kazuha.png",
        elementEnergy: 0,
      );

      // 自陣
      newField[7][2] = Character(
        type: CharacterType.kazuha,
        elementType: ElementType.anemo,
        isAlly: true,
        imagePath: "lib/assets/images/elemental_strategy/characters/up_kazuha.png",
        elementEnergy: 0,
      );
      newField[7][3] = Character(
        type: CharacterType.venti,
        elementType: ElementType.anemo,
        isAlly: true,
        imagePath: "lib/assets/images/elemental_strategy/characters/up_venti.png",
        elementEnergy: 0,
      );
      newField[7][4] = Character(
        type: CharacterType.xiao,
        elementType: ElementType.anemo,
        isAlly: true,
        imagePath: "lib/assets/images/elemental_strategy/characters/up_xiao.png",
        elementEnergy: 0,
      );
      newField[7][5] = Character(
        type: CharacterType.yanfei,
        elementType: ElementType.pyro,
        isAlly: true,
        imagePath: "lib/assets/images/elemental_strategy/characters/up_yanfei.png",
        elementEnergy: 0,
      );
    }

    field = newField;
  }

  // CPUへターンを渡す
  void turnChange() {
    setState(() {
      isAllyTurn = !isAllyTurn;
      turnCount++;
    });

    // CPU行動
    cpuActionWithCpuAi();
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
    Map<String, dynamic> toRemove = {};
    Character? newCharacter;

    for (var elementalParticle in elementalParticles) {
      if (elementalParticle["coordinates"][0] == newRow && elementalParticle["coordinates"][1] == newCol) {
        // 元素拾得時、 elementEnergy を更新した Character を生成
        double totalEnergy = selectedCharacter!.elementEnergy + (selectedCharacter!.elementType == elementalParticle["element"].type ? 50 : 25);

        newCharacter = Character(
          type: selectedCharacter!.type,
          elementType: selectedCharacter!.elementType,
          isAlly: selectedCharacter!.isAlly,
          imagePath: selectedCharacter!.imagePath,
          elementEnergy: totalEnergy > 100.0 ? 100.0 : totalEnergy,
        );
        toRemove = elementalParticle;
      }
    }

    setState(() {
      // キャラクターを入れ替え、元素エネルギーを取り除く
      if (newCharacter != null) {
        selectedCharacter = newCharacter;
        elementalParticles.remove(toRemove);
      }

      field[newRow][newCol] = selectedCharacter; // 新しい座標へ移動
      field[selectedRow][selectedCol] = null; //元の座標を初期化

      // 履歴に記録
      var currentLog = "${isAllyTurn ? "自分" : "相手"}の${selectedCharacter!.name()}が [${(newRow + 1).toString()}, ${(newCol + 1).toString()}] に移動";
      history.add(currentLog);

      // キャラクター選択をリセット
      selectedCharacter = null;
      selectedRow = -1;
      selectedCol = -1;
      validMoves = [];
    });

    // ターンチェンジ
    if (isAllyTurn) {
      turnChange();
    }
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
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: MediaQuery.of(context).size.width * 0.95,
            height: MediaQuery.of(context).size.width * 0.3,
            margin: const EdgeInsets.only(top: 50),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(3),
              border: Border.all(color: ColorTable.primaryBlackColor, width: 1.0),
            ),
            child: Center(
              child: Text(
                history.length > 3 ? history.skip(history.length - 3).join("\n") : history.join("\n"),
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  height: 2.0,
                ),
              ),
            ),
          ),
          Expanded(
            child: GridView.builder(
              itemCount: 8 * 8,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 8),
              itemBuilder: (context, index) {
                int row = index ~/ 8;
                int col = index % 8;
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
          Container(
            padding: const EdgeInsets.all(8.0),
            width: MediaQuery.of(context).size.width * 0.95,
            height: MediaQuery.of(context).size.width * 0.3,
            margin: const EdgeInsets.only(bottom: 50),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                GestureDetector(
                  onTap: () {},
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.yellow[400],
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
                  onTap: () {},
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.red[400],
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
    );
  }

  // CPUの行動制御
  void cpuActionWithCpuAi() {
    // 選択できる手を取得
    List<List<Map<String, dynamic>>> candidatePices = enumerateAvailableActions(field);
    List<int> derivedActionPieceCoordinates;
    List<int> candidateMoves;
    var random = Random();

    // キャラクター群からランダムにひとり選ぶ
    int randomIndex = random.nextInt(candidatePices.length);
    derivedActionPieceCoordinates = candidatePices[randomIndex][1]["coordinates"]; // 選ばれたキャラクターの座標

    // キャラクターを選択
    selectCharacter(derivedActionPieceCoordinates[0], derivedActionPieceCoordinates[1]);

    // 動かせないキャラクターだった場合は再計算
    while (validMoves.isEmpty) {
      int randomIndex = random.nextInt(candidatePices.length);
      derivedActionPieceCoordinates = candidatePices[randomIndex][1]["coordinates"]; // 再選択されたキャラクターの座標
    }

    // 移動可能な座標からランダムにひとつ選ぶ
    randomIndex = random.nextInt(validMoves.length);
    candidateMoves = validMoves[randomIndex];

    // 移動実行
    moveCharacter(candidateMoves[0], candidateMoves[1]);

    // プレイヤーへターンを渡す
    setState(() {
      isAllyTurn = !isAllyTurn;
      turnCount++;
    });
  }
}
