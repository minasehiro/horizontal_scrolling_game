import 'dart:math';

import 'package:flutter/material.dart';
import 'package:horizontal_scrolling_game/color_table.dart';
import 'package:horizontal_scrolling_game/elemental_strategy/components/piece.dart';
import 'package:horizontal_scrolling_game/elemental_strategy/components/square.dart';
import 'package:horizontal_scrolling_game/elemental_strategy/helper_methods.dart';
import 'package:horizontal_scrolling_game/elemental_strategy/shogi_ai.dart';

class ElementalStrategy extends StatefulWidget {
  const ElementalStrategy({super.key});

  @override
  State<ElementalStrategy> createState() => _ElementalStrategyState();
}

class _ElementalStrategyState extends State<ElementalStrategy> {
  late List<List<ShogiPiece?>> board; // 盤面管理用の配列
  ShogiPiece? selectedPiece; // 選択されている駒
  int selectedRow = -1; // 選択されている駒の行番号
  int selectedCol = -1; // 選択されている駒の列番号
  List<List<int>> validMoves = []; // 移動可能な座標の配列
  bool isAllyTurn = true; // 味方のターンかどうか
  bool isSelectingDropPosition = false; // 手持ちの駒を打とうとしている
  int turnCount = 1; // 経過ターン
  String currentLog = "対戦開始！！";
  List<String> coordinatesHistory = []; // ログ

  @override
  void initState() {
    super.initState();

    _initializeBoard();
  }

  // 盤面の初期化
  void _initializeBoard() {
    List<List<ShogiPiece?>> newBoard = List.generate(8, (index) => List.generate(8, (index) => null));

    for (int i = 0; i < 8; i++) {
      // 敵陣
      newBoard[0][2] = ShogiPiece(
        type: ShogiPieceType.ousho,
        isAlly: false,
        imagePath: "lib/assets/images/elemental_strategy/kazuha.png",
        isPromoted: false,
      );
      newBoard[0][3] = ShogiPiece(
        type: ShogiPieceType.ousho,
        isAlly: false,
        imagePath: "lib/assets/images/elemental_strategy/venti.png",
        isPromoted: false,
      );
      newBoard[0][4] = ShogiPiece(
        type: ShogiPieceType.ousho,
        isAlly: false,
        imagePath: "lib/assets/images/elemental_strategy/yanfei.png",
        isPromoted: false,
      );
      newBoard[0][5] = ShogiPiece(
        type: ShogiPieceType.ousho,
        isAlly: false,
        imagePath: "lib/assets/images/elemental_strategy/xiao.png",
        isPromoted: false,
      );

      // 自陣
      newBoard[7][2] = ShogiPiece(
        type: ShogiPieceType.ousho,
        isAlly: true,
        imagePath: "lib/assets/images/elemental_strategy/kazuha.png",
        isPromoted: false,
      );
      newBoard[7][3] = ShogiPiece(
        type: ShogiPieceType.ousho,
        isAlly: true,
        imagePath: "lib/assets/images/elemental_strategy/venti.png",
        isPromoted: false,
      );
      newBoard[7][4] = ShogiPiece(
        type: ShogiPieceType.ousho,
        isAlly: true,
        imagePath: "lib/assets/images/elemental_strategy/yanfei.png",
        isPromoted: false,
      );
      newBoard[7][5] = ShogiPiece(
        type: ShogiPieceType.ousho,
        isAlly: true,
        imagePath: "lib/assets/images/elemental_strategy/xiao.png",
        isPromoted: false,
      );
    }

    board = newBoard;
  }

  // CPUへターンを渡す
  void turnChange() {
    setState(() {
      isAllyTurn = !isAllyTurn;
      turnCount++;
    });

    // CPU行動
    cpuActionWithShogiAi();
  }

  // ピースを選択する
  void selectPiece(int row, int col) {
    setState(() {
      // 駒を選択していない状態から駒を選択した時
      if (selectedPiece == null && board[row][col] != null) {
        if (board[row][col]!.isAlly == isAllyTurn) {
          selectedPiece = board[row][col];
          selectedRow = row;
          selectedCol = col;
        }
        // 駒を選択している状態で自陣の他の駒を選択した時
      } else if (board[row][col] != null && board[row][col]!.isAlly == selectedPiece!.isAlly) {
        selectedPiece = board[row][col];
        selectedRow = row;
        selectedCol = col;
        isSelectingDropPosition = false;
        // 移動可能な座標を選択した時
      } else if (selectedPiece != null && validMoves.any((coordinate) => coordinate[0] == row && coordinate[1] == col)) {
        if (board[row][col] != null) {
          print(coordinatesHistory);
        }

        movePiece(row, col);
      }

      validMoves = calculateRawValidMoves(selectedRow, selectedCol, selectedPiece); // 移動可能な座標を再計算
    });
  }

  // 駒が移動可能な座標を配列で返す
  List<List<int>> calculateRawValidMoves(int row, int col, ShogiPiece? piece) {
    if (piece == null) {
      return [];
    }

    List<List<int>> candidateMoves = [];

    switch (piece.type) {
      case ShogiPieceType.ousho: // 王将
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
          var newRow = row + (direction[0]);
          var newCol = col + (direction[1]);

          // 盤面から出た場合
          if (!isInBoard(newRow, newCol)) {
            continue;
          }

          // 対象の座標に駒がある
          if (board[newRow][newCol] != null) {
            // 対象の駒が敵
            if (board[newRow][newCol]!.isAlly != piece.isAlly) {
              candidateMoves.add([newRow, newCol]);
            }
            continue;
          }

          candidateMoves.add([newRow, newCol]);
        }

        break;
      default:
    }

    return candidateMoves;
  }

  // 対象の座標が盤面にあるか
  bool isInBoard(int row, int col) {
    return row >= 0 && row < 8 && col >= 0 && col < 8;
  }

  // 駒を移動
  void movePiece(int newRow, int newCol) async {
    board[newRow][newCol] = selectedPiece; // 新しい座標へ移動
    board[selectedRow][selectedCol] = null; //元の座標を初期化

    // 現在の選択をリセット
    setState(() {
      currentLog = "${isAllyTurn ? "自分" : "相手"}の${selectedPiece!.typeStr()}が${(newRow + 1).toString()}${toKanjiNumeral(newCol + 1)}に移動";

      // 棋譜に記録
      coordinatesHistory.add("ターン$turnCount: $currentLog");

      selectedPiece = null;
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
          Expanded(
            flex: 1,
            child: Container(
              margin: const EdgeInsets.only(top: 50),
              child: const Center(
                child: Text(
                  "相手のステータス",
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Container(
              padding: const EdgeInsets.all(8.0),
              width: MediaQuery.of(context).size.width * 0.95,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(3),
                border: Border.all(color: ColorTable.primaryBlackColor, width: 1.0),
              ),
              child: Center(
                child: Text(
                  currentLog,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            flex: 4,
            child: GridView.builder(
              itemCount: 8 * 8,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 8),
              itemBuilder: (context, index) {
                int row = index ~/ 8;
                int col = index % 8;
                bool isSelected = row == selectedRow && col == selectedCol;
                bool isValidMove = false;
                bool isHoheiLineUpVertically = false;

                // 選択中の駒が移動可能な座標かどうか
                for (var position in validMoves) {
                  if (position[0] == row && position[1] == col) {
                    isValidMove = true;
                  }
                }

                return Square(
                  piece: board[row][col],
                  isSelected: isSelected,
                  isValidMove: isValidMove,
                  onTap: () => selectPiece(row, col),
                  isSelectingDropPosition: isSelectingDropPosition,
                  isHoheiLineUpVertically: isHoheiLineUpVertically,
                );
              },
            ),
          ),
          Expanded(
            flex: 1,
            child: Container(
              margin: const EdgeInsets.only(bottom: 50),
              child: const Center(
                child: Text("自分のステータス"),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // CPUの行動制御
  void cpuActionWithShogiAi() {
    // 選択できる手を取得
    List<List<Map<String, dynamic>>> candidatePices = enumerateAvailableActions(board);
    List<int> derivedActionPieceCoordinates;
    List<int> candidateMoves;
    var random = Random();

    // 駒群からランダムにひとつ駒を選ぶ
    int randomIndex = random.nextInt(candidatePices.length);
    derivedActionPieceCoordinates = candidatePices[randomIndex][1]["coordinates"]; // 導き出された駒の座標

    // ピースを選択
    selectPiece(derivedActionPieceCoordinates[0], derivedActionPieceCoordinates[1]);

    // 動かせない駒だった場合は再計算
    while (validMoves.isEmpty) {
      int randomIndex = random.nextInt(candidatePices.length);
      derivedActionPieceCoordinates = candidatePices[randomIndex][1]["coordinates"]; // 再計算された駒の座標
    }

    // 移動可能な座標からランダムにひとつ選ぶ
    randomIndex = random.nextInt(validMoves.length);
    candidateMoves = validMoves[randomIndex];

    // 移動実行
    movePiece(candidateMoves[0], candidateMoves[1]);

    // プレイヤーへターンを渡す
    setState(() {
      isAllyTurn = !isAllyTurn;
      turnCount++;
    });
  }
}
