import 'dart:math';
import 'package:flutter/material.dart';
import './components/damage.dart';
import './components/elemental_burst.dart';
import './components/elemental_skill.dart';
import '../color_table.dart';
import '../home_page.dart';
import './components/character.dart';
import './components/element_particle.dart';
import './components/square.dart';
import '../constants.dart';
import './helper_methods.dart';

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
  int turnCount = 1; // 経過ターン
  List<Map<String, dynamic>> elementalParticles = []; // 元素粒子の種類と発生座標
  List<ElementParticle> allyElements = [
    ElementParticle(type: ElementType.anemo, imagePath: "lib/assets/images/elements/anemo.png", color: ColorTable.anemoColor),
    ElementParticle(type: ElementType.cryo, imagePath: "lib/assets/images/elements/cryo.png", color: ColorTable.cryoColor),
    ElementParticle(type: ElementType.electro, imagePath: "lib/assets/images/elements/electro.png", color: ColorTable.electroColor),
    ElementParticle(type: ElementType.hydro, imagePath: "lib/assets/images/elements/hydro.png", color: ColorTable.hydroColor),
  ];
  List<ElementParticle> enemyElements = [
    ElementParticle(type: ElementType.pyro, imagePath: "lib/assets/images/elements/pyro.png", color: ColorTable.pyroColor),
    ElementParticle(type: ElementType.anemo, imagePath: "lib/assets/images/elements/anemo.png", color: ColorTable.anemoColor),
    ElementParticle(type: ElementType.dendro, imagePath: "lib/assets/images/elements/dendro.png", color: ColorTable.dendroColor),
    ElementParticle(type: ElementType.geo, imagePath: "lib/assets/images/elements/geo.png", color: ColorTable.geoColor),
  ];
  bool isLaunchElementalBurst = false; // 元素爆発を発動
  bool isLaunchElementalSkill = false; // 元素スキルを発動
  late AnimationController animationController; // カットイン
  late Animation<Offset> offsetAnimation; // カットイン
  late TweenSequence<Offset> tweenSequence; // カットイン

  late List<Character> fieldCharacters; // 選択されたキャラクター一覧
  int currentCharacterIndex = 0; // 行動するキャラクター
  List<List<int>> attackRange = []; // 攻撃予測範囲
  List<Map<String, dynamic>> currentDamages = []; // 発生したダメージ

  @override
  void initState() {
    super.initState();

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
        skill: ElementalSkill(
          name: "千早振る",
          voice: "風を知れ",
          elementType: ElementType.anemo,
          damage: 30,
          damageRange: [
            [-1, 0], // 上
            [1, 0], // 下
            [0, -1], // 左
            [0, 1], // 右
            [-1, -1], // 左上
            [-1, 1], // 右上
            [1, -1], // 左下
            [1, 1], // 右下
          ],
          coolTime: 2,
          numberOfParticlesGenerated: 40,
        ),
        turnLastTriggeredSkill: 0,
        burst: ElementalBurst(
          name: "万葉の一刀",
          voice: "雲隠れ、雁鳴くとき",
          elementType: ElementType.anemo,
          damage: 30,
          damageRange: [
            [0, -1],
            [0, -2],
            [0, -3],
          ],
          coolTime: 3,
        ),
        turnLastTriggeredBurst: 0,
      ),
      Character(
        type: CharacterType.zhongli,
        elementType: ElementType.geo,
        isAlly: false,
        imagePath: "lib/assets/images/elemental_strategy/characters/down_zhongli.png",
        elementEnergy: 0,
        hitPoint: 100,
        currentRow: 0,
        currentCol: 4,
        skill: ElementalSkill(
          name: "地心",
          voice: "壁立千仞！",
          elementType: ElementType.geo,
          damage: 10,
          damageRange: [
            [0, -1],
          ],
          coolTime: 2,
          numberOfParticlesGenerated: 20,
        ),
        turnLastTriggeredSkill: 0,
        burst: ElementalBurst(
          name: "天星",
          voice: "天道、ここに在り",
          elementType: ElementType.geo,
          damage: 10,
          damageRange: [
            [0, -1],
            [0, -2],
            [0, -3],
          ],
          coolTime: 1,
        ),
        turnLastTriggeredBurst: 0,
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
        skill: ElementalSkill(
          name: "神里流・氷華",
          voice: "雪よ、舞え。",
          elementType: ElementType.cryo,
          damage: 40,
          damageRange: [
            [-1, 0], // 上
            [1, 0], // 下
            [0, -1], // 左
            [0, 1], // 右
            [-1, -1], // 左上
            [-1, 1], // 右上
            [1, -1], // 左下
            [1, 1], // 右下
          ],
          coolTime: 2,
          numberOfParticlesGenerated: 30,
        ),
        turnLastTriggeredSkill: 0,
        burst: ElementalBurst(
          name: "神里流・霜滅",
          voice: "櫻吹雪！",
          elementType: ElementType.cryo,
          damage: 10,
          damageRange: [
            [0, -1],
            [0, -2],
            [0, -3],
          ],
          coolTime: 1,
        ),
        turnLastTriggeredBurst: 0,
      ),
      Character(
        type: CharacterType.nahida,
        elementType: ElementType.dendro,
        isAlly: false,
        imagePath: "lib/assets/images/elemental_strategy/characters/down_nahida.png",
        elementEnergy: 0,
        hitPoint: 100,
        currentRow: 0,
        currentCol: 3,
        skill: ElementalSkill(
          name: "諸聞遍計",
          voice: "蔓延りなさい。",
          elementType: ElementType.dendro,
          damage: 10,
          damageRange: [
            [1, 0], [2, 0], [3, 0], // 下
            [1, -1], [2, -2], [3, -3], // 左下
            [1, 1], [2, 2], [3, 3], // 右下
            [2, -1], [3, -1], [3, -2], [2, 1], [3, 1], [3, 2],
          ],
          coolTime: 1,
          numberOfParticlesGenerated: 30,
        ),
        turnLastTriggeredSkill: 0,
        burst: ElementalBurst(
          name: "心景幻成",
          voice: "知識を、あなたにも。",
          elementType: ElementType.dendro,
          damage: 10,
          damageRange: [
            [0, -1],
            [0, -2],
            [0, -3],
          ],
          coolTime: 1,
        ),
        turnLastTriggeredBurst: 0,
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
        skill: ElementalSkill(
          name: "野干役呪・殺生櫻",
          voice: "具現化せよ。",
          elementType: ElementType.electro,
          damage: 0,
          damageRange: [],
          coolTime: 1,
          numberOfParticlesGenerated: 0,
        ),
        turnLastTriggeredSkill: 0,
        burst: ElementalBurst(
          name: "大密法・天狐顕現",
          voice: "雷光、いと美しきかな。",
          elementType: ElementType.electro,
          damage: 10,
          damageRange: [
            [0, -1],
            [0, -2],
            [0, -3],
          ],
          coolTime: 1,
        ),
        turnLastTriggeredBurst: 0,
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
        skill: ElementalSkill(
          name: "風輪両立",
          voice: "無駄だ。",
          elementType: ElementType.anemo,
          damage: 30,
          damageRange: [
            [1, 0],
            [2, 0],
          ],
          coolTime: 1,
          numberOfParticlesGenerated: 20,
        ),
        turnLastTriggeredSkill: 0,
        burst: ElementalBurst(
          name: "靖妖儺舞",
          voice: "喚くがいい！！",
          elementType: ElementType.anemo,
          damage: 10,
          damageRange: [
            [0, -1],
            [0, -2],
            [0, -3],
          ],
          coolTime: 1,
        ),
        turnLastTriggeredBurst: 0,
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
        skill: ElementalSkill(
          name: "古華剣・裁雨留虹",
          voice: "この剣はわかるかい？",
          elementType: ElementType.hydro,
          damage: 30,
          damageRange: [
            [-1, 0],
          ],
          coolTime: 3,
          numberOfParticlesGenerated: 40,
        ),
        turnLastTriggeredSkill: 0,
        burst: ElementalBurst(
          name: "古華剣・画雨籠山",
          voice: "古華奥義！",
          elementType: ElementType.hydro,
          damage: 10,
          damageRange: [
            [0, -1],
            [0, -2],
            [0, -3],
          ],
          coolTime: 1,
        ),
        turnLastTriggeredBurst: 0,
      ),
      Character(
        type: CharacterType.yanfei,
        elementType: ElementType.pyro,
        isAlly: false,
        imagePath: "lib/assets/images/elemental_strategy/characters/down_yanfei.png",
        elementEnergy: 0,
        hitPoint: 100,
        currentRow: 0,
        currentCol: 1,
        skill: ElementalSkill(
          name: "丹書契約",
          voice: "燃えよ♪",
          elementType: ElementType.pyro,
          damage: 10,
          damageRange: [
            [0, -1],
            [0, -2],
            [0, -3],
          ],
          coolTime: 1,
          numberOfParticlesGenerated: 20,
        ),
        turnLastTriggeredSkill: 0,
        burst: ElementalBurst(
          name: "契約成立",
          voice: "丹書鉄契！",
          elementType: ElementType.pyro,
          damage: 10,
          damageRange: [
            [0, -1],
            [0, -2],
            [0, -3],
          ],
          coolTime: 1,
        ),
        turnLastTriggeredBurst: 0,
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
            skill: selectedCharacter!.skill,
            turnLastTriggeredSkill: selectedCharacter!.turnLastTriggeredSkill,
            burst: selectedCharacter!.burst,
            turnLastTriggeredBurst: turnCount,
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
            // 付近にいたキャラにダメージを与え、新しいHPでフィールドに再展開
            for (var targetCoordinate in targetCoordinates) {
              Character? targetCharacter = field[targetCoordinate[0]][targetCoordinate[1]];
              double remainingHitPoint = targetCharacter!.hitPoint - selectedCharacter!.burst.damage;

              // ダメージを生成
              currentDamages.add({
                "coordinates": [targetCoordinate[0], targetCoordinate[1]],
                "object": Damage(elementType: selectedCharacter!.elementType, value: selectedCharacter!.burst.damage, isCritical: false),
              });

              if (remainingHitPoint <= 0) {
                field[targetCoordinate[0]][targetCoordinate[1]] = null;
                fieldCharacters.removeWhere((character) => character.type == targetCharacter.type);

                isGameOver();
              } else {
                var newCharacter = Character(
                  type: targetCharacter.type,
                  elementType: targetCharacter.elementType,
                  isAlly: targetCharacter.isAlly,
                  imagePath: targetCharacter.imagePath,
                  elementEnergy: targetCharacter.elementEnergy,
                  hitPoint: remainingHitPoint,
                  currentRow: targetCharacter.currentRow,
                  currentCol: targetCharacter.currentCol,
                  skill: targetCharacter.skill,
                  turnLastTriggeredSkill: targetCharacter.turnLastTriggeredSkill,
                  burst: targetCharacter.burst,
                  turnLastTriggeredBurst: targetCharacter.turnLastTriggeredBurst,
                );

                // キャラクターを再展開
                field[targetCoordinate[0]][targetCoordinate[1]] = newCharacter;
                int targetIndex = fieldCharacters.indexWhere((character) => character.type == targetCharacter.type);
                fieldCharacters[targetIndex] = newCharacter;
              }
            }

            // 元素爆発を終了
            isLaunchElementalBurst = false;

            // 元素エネルギーを減らしたキャラをフィールドに再展開
            field[selectedRow][selectedCol] = newCharacter;
            int targetIndex = fieldCharacters.indexWhere((character) => character.type == newCharacter.type);
            fieldCharacters[targetIndex] = newCharacter;

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
          var newCharacter = Character(
            type: selectedCharacter!.type,
            elementType: selectedCharacter!.elementType,
            isAlly: selectedCharacter!.isAlly,
            imagePath: selectedCharacter!.imagePath,
            elementEnergy: selectedCharacter!.elementEnergy,
            hitPoint: selectedCharacter!.hitPoint,
            currentRow: selectedCharacter!.currentRow,
            currentCol: selectedCharacter!.currentCol,
            skill: selectedCharacter!.skill,
            turnLastTriggeredSkill: turnCount,
            burst: selectedCharacter!.burst,
            turnLastTriggeredBurst: selectedCharacter!.turnLastTriggeredBurst,
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
            // 付近にいたキャラにダメージを与え、新しいHPでフィールドに再展開
            for (var targetCoordinate in targetCoordinates) {
              Character? targetCharacter = field[targetCoordinate[0]][targetCoordinate[1]];
              double remainingHitPoint = targetCharacter!.hitPoint - selectedCharacter!.skill.damage;

              // ダメージを生成
              currentDamages.add({
                "coordinates": [targetCoordinate[0], targetCoordinate[1]],
                "object": Damage(elementType: selectedCharacter!.elementType, value: selectedCharacter!.skill.damage, isCritical: false),
              });

              if (remainingHitPoint <= 0) {
                field[targetCoordinate[0]][targetCoordinate[1]] = null;
                fieldCharacters.removeWhere((character) => character.type == targetCharacter.type);

                isGameOver();
              } else {
                var newCharacter = Character(
                  type: targetCharacter.type,
                  elementType: targetCharacter.elementType,
                  isAlly: targetCharacter.isAlly,
                  imagePath: targetCharacter.imagePath,
                  elementEnergy: targetCharacter.elementEnergy,
                  hitPoint: remainingHitPoint,
                  currentRow: targetCharacter.currentRow,
                  currentCol: targetCharacter.currentCol,
                  skill: targetCharacter.skill,
                  turnLastTriggeredSkill: targetCharacter.turnLastTriggeredSkill,
                  burst: targetCharacter.burst,
                  turnLastTriggeredBurst: targetCharacter.turnLastTriggeredBurst,
                );

                // キャラクターを再展開
                field[targetCoordinate[0]][targetCoordinate[1]] = newCharacter;
                int targetIndex = fieldCharacters.indexWhere((character) => character.type == targetCharacter.type);
                fieldCharacters[targetIndex] = newCharacter;
              }
            }

            // 元素スキル処理を終了
            isLaunchElementalSkill = false;

            // スキル発動ターンをセットし、キャラクターを再展開
            field[selectedRow][selectedCol] = newCharacter;
            int targetIndex = fieldCharacters.indexWhere((character) => character.type == newCharacter.type);
            fieldCharacters[targetIndex] = newCharacter;

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
      selectedRow = selectedCharacter!.currentRow;
      selectedCol = selectedCharacter!.currentCol;
      validMoves = calculateRawValidMoves(field, selectedRow, selectedCol, selectedCharacter); // 移動可能な座標を計算

      if (!selectedCharacter!.isAlly) {
        cpuActionWithCpuAi();
      }
    });
  }

  // フィールドのマスを選択したときに呼ばれる
  void selectSquare(int row, int col) {
    setState(() {
      // 移動可能な座標を選択した時
      if (selectedCharacter != null && validMoves.any((coordinate) => coordinate[0] == row && coordinate[1] == col)) {
        moveCharacter(row, col);
      }
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
      elementEnergy: totalEnergy > 100 ? 100 : totalEnergy,
      hitPoint: selectedCharacter!.hitPoint,
      currentRow: newRow,
      currentCol: newCol,
      skill: selectedCharacter!.skill,
      turnLastTriggeredSkill: selectedCharacter!.turnLastTriggeredSkill,
      burst: selectedCharacter!.burst,
      turnLastTriggeredBurst: selectedCharacter!.turnLastTriggeredBurst,
    );

    setState(() {
      // キャラクターを入れ替え、元素エネルギーを取り除く
      if (toRemove != {}) {
        elementalParticles.remove(toRemove);
      }

      field[newRow][newCol] = newCharacter; // 新しい座標へ移動
      fieldCharacters[currentCharacterIndex] = newCharacter!;
      field[selectedRow][selectedCol] = null; //元の座標を初期化
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

  // 攻撃可能範囲を表示
  void showAttackRange(damageRange, character) {
    setState(() {
      attackRange = calculateAttackRange(field, selectedRow, selectedCol, damageRange, character);
    });
  }

  // 攻撃可能範囲を非表示
  void hideAttackRange() {
    setState(() {
      attackRange = [];
    });
  }

  // どちらかのキャラクターがいなくなった場合、ダイアログを表示
  void isGameOver() {
    if (fieldCharacters.every((character) => character.isAlly) || fieldCharacters.every((character) => !character.isAlly)) {
      showDialog(
        barrierDismissible: false,
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Center(
              child: Column(
                children: [
                  Text(
                    "ゲーム終了",
                  ),
                ],
              ),
            ),
            actions: [
              GestureDetector(
                onTap: () {
                  // ゲームの初期化
                  resetGame();

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
                      'ホームへ',
                      style: TextStyle(color: ColorTable.primaryNavyColor),
                    ),
                  ),
                ),
              ),
            ],
            actionsAlignment: MainAxisAlignment.center,
          );
        },
      );
    }
  }

  // 初期化
  void resetGame() {}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
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
                    bool canAttackRange = false;
                    ElementParticle? element;
                    Damage? damageObject;

                    if (attackRange.isEmpty) {
                      // 選択中のキャラクターが移動可能な座標かどうか
                      for (var position in validMoves) {
                        if (position[0] == row && position[1] == col) {
                          isValidMove = true;
                        }
                      }
                    } else {
                      // 選択中のキャラクターが攻撃可能な座標かどうか
                      for (var range in attackRange) {
                        if (range[0] == row && range[1] == col) {
                          canAttackRange = true;
                        }
                      }
                    }

                    // 元素粒子が発生しているかどうか
                    for (var elementalParticle in elementalParticles) {
                      if (elementalParticle["coordinates"][0] == row && elementalParticle["coordinates"][1] == col) {
                        element = elementalParticle["element"];
                      }
                    }

                    // ダメージが発生しているかどうか
                    for (var damage in currentDamages) {
                      if (damage["coordinates"][0] == row && damage["coordinates"][1] == col) {
                        damageObject = damage["object"];
                      }
                    }

                    return Square(
                      piece: field[row][col],
                      isSelected: isSelected,
                      isValidMove: isValidMove,
                      canAttackRange: canAttackRange,
                      onTap: () => selectSquare(row, col),
                      element: element,
                      damage: damageObject,
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
                        if (canLaunchElementalSkill(selectedCharacter, turnCount)) {
                          launchElementalSkill(selectedCharacter);
                        }
                      },
                      onLongPressStart: (details) {
                        showAttackRange(selectedCharacter!.skill.damageRange, selectedCharacter);
                      },
                      onLongPressEnd: (details) {
                        hideAttackRange();
                      },
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: canLaunchElementalSkill(selectedCharacter, turnCount) ? Colors.red[400] : Colors.grey[300],
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
                        if (canLaunchElementalBurst(selectedCharacter, turnCount)) {
                          launchElementalBurst(selectedCharacter);
                        }
                      },
                      onLongPressStart: (details) {
                        showAttackRange(selectedCharacter!.burst.damageRange, selectedCharacter);
                      },
                      onLongPressEnd: (details) {
                        hideAttackRange();
                      },
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: canLaunchElementalBurst(selectedCharacter, turnCount) ? Colors.yellow[400] : Colors.grey[300],
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
