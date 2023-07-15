import 'dart:math';

import 'package:flutter/material.dart';
import 'package:horizontal_scrolling_game/color_table.dart';
import 'package:horizontal_scrolling_game/home_page.dart';
import 'package:horizontal_scrolling_game/shogi/components/dead_piece.dart';
import 'package:horizontal_scrolling_game/shogi/components/piece.dart';
import 'package:horizontal_scrolling_game/shogi/components/square.dart';
import 'package:horizontal_scrolling_game/shogi/helper_methods.dart';
import 'package:horizontal_scrolling_game/shogi/shogi_ai.dart';

// TODO: 成る時にフリップアニメーションしたい
// TODO: 棋譜は右上から数えるらしい。成ったかどうかも書くらしい
// TODO: 駒の移動の過程を見せるために1ずつ移動させてもいいかも
// TODO: メッセージウィンドウほしい

class Shogi extends StatefulWidget {
  const Shogi({super.key});

  @override
  State<Shogi> createState() => _ShogiState();
}

class _ShogiState extends State<Shogi> with TickerProviderStateMixin {
  late List<List<ShogiPiece?>> board; // 盤面管理用の配列
  ShogiPiece? selectedPiece; // 選択されている駒
  int selectedRow = -1; // 選択されている駒の行番号
  int selectedCol = -1; // 選択されている駒の列番号
  List<List<int>> validMoves = []; // 移動可能な座標の配列
  List<ShogiPiece> piecesTakenByAlly = []; // 味方が獲得した駒の配列
  List<ShogiPiece> piecesTakenByEnemy = []; // 敵が獲得した駒の配列
  bool isAllyTurn = true; // 味方のターンかどうか
  List<int> allyKingPosition = [8, 4]; // 味方の玉将の初期位置
  List<int> enemyKingPosition = [0, 4]; // 敵の王将の初期位置
  bool isCheck = false; // 王手がかかっているかどうか
  bool isSelectingDropPosition = false; // 手持ちの駒を打とうとしている
  int turnCount = 1; // 経過ターン
  List<String> coordinatesHistory = []; // 棋譜
  List<ShogiPieceType> promotablePieceTypes = [
    ShogiPieceType.hisya, // 飛
    ShogiPieceType.kakugyo, // 角
    ShogiPieceType.keima, // 桂馬
    ShogiPieceType.kyousya, // 香車
    ShogiPieceType.ginsho, // 銀
    ShogiPieceType.hohei, // 歩
  ]; // 成れる駒

  @override
  void initState() {
    super.initState();

    _initializeBoard();
  }

  // 盤面の初期化
  void _initializeBoard() {
    List<List<ShogiPiece?>> newBoard = List.generate(9, (index) => List.generate(9, (index) => null));

    for (int i = 0; i < 9; i++) {
      // 敵陣
      newBoard[0][0] = ShogiPiece(
        type: ShogiPieceType.kyousya,
        isAlly: false,
        imagePath: "lib/assets/images/shogi/down_kyousya.png",
        isPromoted: false,
      );
      newBoard[0][1] = ShogiPiece(
        type: ShogiPieceType.keima,
        isAlly: false,
        imagePath: "lib/assets/images/shogi/down_keima.png",
        isPromoted: false,
      );
      newBoard[0][2] = ShogiPiece(
        type: ShogiPieceType.ginsho,
        isAlly: false,
        imagePath: "lib/assets/images/shogi/down_ginsho.png",
        isPromoted: false,
      );
      newBoard[0][3] = ShogiPiece(
        type: ShogiPieceType.kinsho,
        isAlly: false,
        imagePath: "lib/assets/images/shogi/down_kinsho.png",
        isPromoted: false,
      );
      newBoard[0][4] = ShogiPiece(
        type: ShogiPieceType.ousho,
        isAlly: false,
        imagePath: "lib/assets/images/shogi/down_ousho.png",
        isPromoted: false,
      );
      newBoard[0][5] = ShogiPiece(
        type: ShogiPieceType.kinsho,
        isAlly: false,
        imagePath: "lib/assets/images/shogi/down_kinsho.png",
        isPromoted: false,
      );
      newBoard[0][6] = ShogiPiece(
        type: ShogiPieceType.ginsho,
        isAlly: false,
        imagePath: "lib/assets/images/shogi/down_ginsho.png",
        isPromoted: false,
      );
      newBoard[0][7] = ShogiPiece(
        type: ShogiPieceType.keima,
        isAlly: false,
        imagePath: "lib/assets/images/shogi/down_keima.png",
        isPromoted: false,
      );
      newBoard[0][8] = ShogiPiece(
        type: ShogiPieceType.kyousya,
        isAlly: false,
        imagePath: "lib/assets/images/shogi/down_kyousya.png",
        isPromoted: false,
      );
      newBoard[1][1] = ShogiPiece(
        type: ShogiPieceType.hisya,
        isAlly: false,
        imagePath: "lib/assets/images/shogi/down_hisya.png",
        isPromoted: false,
      );
      newBoard[1][7] = ShogiPiece(
        type: ShogiPieceType.kakugyo,
        isAlly: false,
        imagePath: "lib/assets/images/shogi/down_kakugyo.png",
        isPromoted: false,
      );
      newBoard[2][i] = ShogiPiece(
        type: ShogiPieceType.hohei,
        isAlly: false,
        imagePath: "lib/assets/images/shogi/down_hohei.png",
        isPromoted: false,
      );

      // 自陣
      newBoard[6][i] = ShogiPiece(
        type: ShogiPieceType.hohei,
        isAlly: true,
        imagePath: "lib/assets/images/shogi/up_hohei.png",
        isPromoted: false,
      );
      newBoard[7][1] = ShogiPiece(
        type: ShogiPieceType.kakugyo,
        isAlly: true,
        imagePath: "lib/assets/images/shogi/up_kakugyo.png",
        isPromoted: false,
      );
      newBoard[7][7] = ShogiPiece(
        type: ShogiPieceType.hisya,
        isAlly: true,
        imagePath: "lib/assets/images/shogi/up_hisya.png",
        isPromoted: false,
      );
      newBoard[8][0] = ShogiPiece(
        type: ShogiPieceType.kyousya,
        isAlly: true,
        imagePath: "lib/assets/images/shogi/up_kyousya.png",
        isPromoted: false,
      );
      newBoard[8][1] = ShogiPiece(
        type: ShogiPieceType.keima,
        isAlly: true,
        imagePath: "lib/assets/images/shogi/up_keima.png",
        isPromoted: false,
      );
      newBoard[8][2] = ShogiPiece(
        type: ShogiPieceType.ginsho,
        isAlly: true,
        imagePath: "lib/assets/images/shogi/up_ginsho.png",
        isPromoted: false,
      );
      newBoard[8][3] = ShogiPiece(
        type: ShogiPieceType.kinsho,
        isAlly: true,
        imagePath: "lib/assets/images/shogi/up_kinsho.png",
        isPromoted: false,
      );
      newBoard[8][4] = ShogiPiece(
        type: ShogiPieceType.gyokusho,
        isAlly: true,
        imagePath: "lib/assets/images/shogi/up_gyokusho.png",
        isPromoted: false,
      );
      newBoard[8][5] = ShogiPiece(
        type: ShogiPieceType.kinsho,
        isAlly: true,
        imagePath: "lib/assets/images/shogi/up_kinsho.png",
        isPromoted: false,
      );
      newBoard[8][6] = ShogiPiece(
        type: ShogiPieceType.ginsho,
        isAlly: true,
        imagePath: "lib/assets/images/shogi/up_ginsho.png",
        isPromoted: false,
      );
      newBoard[8][7] = ShogiPiece(
        type: ShogiPieceType.keima,
        isAlly: true,
        imagePath: "lib/assets/images/shogi/up_keima.png",
        isPromoted: false,
      );
      newBoard[8][8] = ShogiPiece(
        type: ShogiPieceType.kyousya,
        isAlly: true,
        imagePath: "lib/assets/images/shogi/up_kyousya.png",
        isPromoted: false,
      );
    }

    board = newBoard;
  }

  // ターン切り替え
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
        movePiece(row, col);
        // 持ち駒を空き座標に打った時
      } else if (isSelectingDropPosition && board[row][col] == null) {
        // 空き座標にセット
        board[row][col] = selectedPiece;

        // 持ち駒から削除
        if (selectedPiece!.isAlly) {
          piecesTakenByAlly.remove(selectedPiece);
        } else {
          piecesTakenByEnemy.remove(selectedPiece);
        }

        // 王手がかかっているかチェック
        if (isKingInCheck(isAllyTurn)) {
          isCheck = true;
        } else {
          isCheck = false;
        }

        // 棋譜に記録
        coordinatesHistory.add("${toKanjiNumeral(selectedRow + 1)}${selectedCol.toString()}${selectedPiece!.typeStr()}");
        print(coordinatesHistory);

        // 現在の選択をリセット
        selectedPiece = null;
        selectedRow = -1;
        selectedCol = -1;
        validMoves = [];
        isSelectingDropPosition = false;

        // 詰んでいた場合ダイアログを表示
        if (isCheckMate(isAllyTurn)) {
          showDialog(
            barrierDismissible: false,
            context: context,
            builder: (context) {
              return AlertDialog(
                title: const Center(
                  child: Column(
                    children: [
                      Text(
                        "詰みです",
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
                          'ホーム',
                          style: TextStyle(color: ColorTable.primaryNavyColor),
                        ),
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      // ダイアログを閉じる
                      Navigator.pop(context);
                    },
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(5),
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        color: ColorTable.primaryWhiteColor,
                        child: const Text(
                          '盤面を見る',
                          style: TextStyle(color: ColorTable.primaryNavyColor),
                        ),
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      // ゲームの初期化
                      resetGame();

                      // ダイアログを閉じる
                      Navigator.pop(context);
                    },
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(5),
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        color: ColorTable.primaryWhiteColor,
                        child: const Text(
                          '再挑戦',
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

        // ターンチェンジ
        turnChange();
      }

      validMoves = calculateRealValidMoves(selectedRow, selectedCol, selectedPiece, true); // 移動可能な座標を再計算
    });
  }

  // 移動可能な座標を配列で返す
  // checkSimulation を true にすることで、「自分の王将・玉将が王手を受けてしまう位置に駒を移動できない」ルールをケアできる
  List<List<int>> calculateRealValidMoves(int currentRow, int currentCol, ShogiPiece? piece, bool checkSimulation) {
    List<List<int>> realValidMoves = [];
    List<List<int>> candidateMoves = calculateRawValidMoves(currentRow, currentCol, piece);

    if (checkSimulation) {
      for (var candidateMove in candidateMoves) {
        int candidateRow = candidateMove[0];
        int candidateCol = candidateMove[1];

        if (simulatedMoveIsSafe(piece!, currentRow, currentCol, candidateRow, candidateCol)) {
          realValidMoves.add(candidateMove);
        }
      }
    } else {
      realValidMoves = candidateMoves;
    }

    return realValidMoves;
  }

  // 移動したのち、王将・玉将が王手をかけられていないかチェック
  bool simulatedMoveIsSafe(ShogiPiece piece, int currentRow, int currentCol, int candidateRow, int candidateCol) {
    ShogiPiece? originalDestinationPiece = board[candidateRow][candidateCol]; // 移動先の駒

    List<int>? currentKingPosition;
    if (piece.type == ShogiPieceType.ousho || piece.type == ShogiPieceType.gyokusho) {
      currentKingPosition = piece.isAlly ? allyKingPosition : enemyKingPosition;

      if (piece.isAlly) {
        allyKingPosition = [candidateRow, candidateCol];
      } else {
        enemyKingPosition = [candidateRow, candidateCol];
      }
    }

    board[candidateRow][candidateCol] = piece;
    board[currentRow][currentCol] = null;

    bool isCheck = isKingInCheck(!piece.isAlly); // 移動先の位置で王手をかけられるかチェック

    board[currentRow][currentCol] = piece; // 駒の位置をもとに戻す
    board[candidateRow][candidateCol] = originalDestinationPiece; // 移動先の座標に元の駒を戻す

    // 王将の位置情報を元に戻す
    if (piece.type == ShogiPieceType.ousho || piece.type == ShogiPieceType.gyokusho) {
      if (piece.isAlly) {
        allyKingPosition = currentKingPosition!;
      } else {
        enemyKingPosition = currentKingPosition!;
      }
    }

    // isCheck == true であれば移動できないので safe ではない
    return !isCheck;
  }

  // 駒が移動可能な座標を配列で返す
  List<List<int>> calculateRawValidMoves(int row, int col, ShogiPiece? piece) {
    if (piece == null) {
      return [];
    }

    List<List<int>> candidateMoves = [];
    int direction = piece.isAlly ? -1 : 1;

    switch (piece.type) {
      case ShogiPieceType.hohei: // 歩兵
        var newRow = row + direction;

        // 盤面から出ていない
        if (isInBoard(newRow, col)) {
          // 空の座標か、敵の座標だった場合
          if (board[newRow][col] == null || board[newRow][col]!.isAlly != piece.isAlly) {
            candidateMoves.add([newRow, col]);
          }
        }

        break;
      case ShogiPieceType.hisya: // 飛車
        var directions = [
          [-1, 0], // 上
          [1, 0], // 下
          [0, -1], // 左
          [0, 1], // 右
        ];

        for (var direction in directions) {
          var i = 1;

          while (true) {
            var newRow = row + (direction[0] * i);
            var newCol = col + (direction[1] * i);

            // 盤面から出た場合
            if (!isInBoard(newRow, newCol)) {
              break;
            }

            // 対象の座標に駒がある
            if (board[newRow][newCol] != null) {
              // 対象の駒が敵
              if (board[newRow][newCol]!.isAlly != piece.isAlly) {
                candidateMoves.add([newRow, newCol]);
              }
              break;
            }

            candidateMoves.add([newRow, newCol]);
            i++;
          }
        }

        break;
      case ShogiPieceType.promotedHisya: // 龍王
        // 上下左右にはいくらでも移動できる
        var runningDirections = [
          [-1, 0], // 上
          [1, 0], // 下
          [0, -1], // 左
          [0, 1], // 右
        ];

        // 斜めにはひとつ移動できる
        var singleDirections = [
          [-1, -1], // 左上
          [-1, 1], // 右上
          [1, -1], // 左下
          [1, 1], // 右下
        ];

        // 上下左右移動判定
        for (var direction in runningDirections) {
          var i = 1;

          while (true) {
            var newRow = row + (direction[0] * i);
            var newCol = col + (direction[1] * i);

            // 盤面から出た場合
            if (!isInBoard(newRow, newCol)) {
              break;
            }

            // 対象の座標に駒がある
            if (board[newRow][newCol] != null) {
              // 対象の駒が敵
              if (board[newRow][newCol]!.isAlly != piece.isAlly) {
                candidateMoves.add([newRow, newCol]);
              }
              break;
            }

            candidateMoves.add([newRow, newCol]);
            i++;
          }
        }

        // 斜め移動判定
        for (var direction in singleDirections) {
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
      case ShogiPieceType.kakugyo: // 角行
        var directions = [
          [-1, -1], // 左上
          [-1, 1], // 右上
          [1, -1], // 左下
          [1, 1], // 右下
        ];

        for (var direction in directions) {
          var i = 1;

          while (true) {
            var newRow = row + (direction[0] * i);
            var newCol = col + (direction[1] * i);

            // 盤面から出た場合
            if (!isInBoard(newRow, newCol)) {
              break;
            }

            // 対象の座標に駒がある
            if (board[newRow][newCol] != null) {
              // 対象の駒が敵
              if (board[newRow][newCol]!.isAlly != piece.isAlly) {
                candidateMoves.add([newRow, newCol]);
              }
              break;
            }

            candidateMoves.add([newRow, newCol]);
            i++;
          }
        }

        break;
      case ShogiPieceType.promotedKakugyo: // 龍馬
        // 斜めにはいくらでも移動できる
        var runningDirections = [
          [-1, -1], // 左上
          [-1, 1], // 右上
          [1, -1], // 左下
          [1, 1], // 右下
        ];

        // 上下左右にはひとつ移動できる
        var singleDirections = [
          [-1, 0], // 上
          [1, 0], // 下
          [0, -1], // 左
          [0, 1], // 右
        ];

        // 斜め移動判定
        for (var direction in runningDirections) {
          var i = 1;

          while (true) {
            var newRow = row + (direction[0] * i);
            var newCol = col + (direction[1] * i);

            // 盤面から出た場合
            if (!isInBoard(newRow, newCol)) {
              break;
            }

            // 対象の座標に駒がある
            if (board[newRow][newCol] != null) {
              // 対象の駒が敵
              if (board[newRow][newCol]!.isAlly != piece.isAlly) {
                candidateMoves.add([newRow, newCol]);
              }
              break;
            }

            candidateMoves.add([newRow, newCol]);
            i++;
          }
        }

        // 上下左右移動判定
        for (var direction in singleDirections) {
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
      case ShogiPieceType.kyousya: // 香車
        var kyousyaMoves = [
          [direction, 0]
        ];

        for (var move in kyousyaMoves) {
          var i = 1;

          while (true) {
            var newRow = row + (move[0] * i);

            // 盤面から出た場合
            if (!isInBoard(newRow, col)) {
              break;
            }

            // 対象の座標に駒がある
            if (board[newRow][col] != null) {
              // 対象の駒が敵
              if (board[newRow][col]!.isAlly != piece.isAlly) {
                candidateMoves.add([newRow, col]);
              }
              break;
            }

            candidateMoves.add([newRow, col]);
            i++;
          }
        }

        break;
      case ShogiPieceType.keima: // 桂馬
        var keimaMoves = [
          [direction * 2, -1], // 左斜め
          [direction * 2, 1], // 右斜め
        ];

        for (var move in keimaMoves) {
          var newRow = row + move[0];
          var newCol = col + move[1];

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
      case ShogiPieceType.ginsho: // 銀将
        var directions = [
          [direction, 0], // 上
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
      case ShogiPieceType.kinsho: // 金将
      case ShogiPieceType.promotedKeima:
      case ShogiPieceType.promotedKyousya:
      case ShogiPieceType.promotedGinsho:
      case ShogiPieceType.promotedHohei:
        var directions = [
          [-1, 0], // 上
          [1, 0], // 下
          [0, -1], // 左
          [0, 1], // 右
          [direction, -1], // 左上
          [direction, 1], // 右上
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
      case ShogiPieceType.gyokusho: // 玉将
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
    return row >= 0 && row < 9 && col >= 0 && col < 9;
  }

  // 駒を移動
  void movePiece(int newRow, int newCol) async {
    if (board[newRow][newCol] != null) {
      var capturedPiece = board[newRow][newCol];

      // 駒の取得
      if (capturedPiece!.isAlly) {
        piecesTakenByEnemy.add(turnOverPiece(capturedPiece));
      } else {
        piecesTakenByAlly.add(turnOverPiece(capturedPiece));
      }
    }

    // 王将の位置を更新
    if (selectedPiece!.type == ShogiPieceType.ousho) {
      enemyKingPosition = [newRow, newCol];
    }

    // 玉将の位置を更新
    if (selectedPiece!.type == ShogiPieceType.gyokusho) {
      allyKingPosition = [newRow, newCol];
    }

    board[newRow][newCol] = selectedPiece; // 新しい座標へ移動
    board[selectedRow][selectedCol] = null; //元の座標を初期化

    // 成りの判定
    if (selectedPiece != null) {
      ShogiPiece currentPiece = selectedPiece!;

      // 成りの対象駒で、まだ成っていない
      if (promotablePieceTypes.contains(currentPiece.type) && !currentPiece.isPromoted) {
        if (currentPiece.isAlly) {
          // 敵陣に入ったか、出た時
          if (newRow <= 2 && selectedRow >= 3 || newRow >= 3 && selectedRow <= 2) {
            await showDialog(
              barrierDismissible: false,
              context: context,
              builder: (context) {
                return AlertDialog(
                  title: const Center(
                    child: Column(
                      children: [
                        Text("成りますか？"),
                      ],
                    ),
                  ),
                  actions: [
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          board[newRow][newCol] = promotePiece(currentPiece); // 成り
                          board[selectedRow][selectedCol] = null; //元の座標を初期化
                        });

                        // ダイアログを閉じる
                        Navigator.pop(context);
                      },
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(5),
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          color: ColorTable.primaryWhiteColor,
                          child: const Text(
                            '成る',
                            style: TextStyle(color: ColorTable.primaryNavyColor),
                          ),
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        // ダイアログを閉じる
                        Navigator.pop(context);
                      },
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(5),
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          color: ColorTable.primaryWhiteColor,
                          child: const Text(
                            'そのまま',
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
        } else {
          // 成りの対象駒かどうか
          if (promotablePieceTypes.contains(currentPiece.type)) {
            // 自陣に入ったか、出た時
            if (newRow >= 6 && selectedRow <= 5 || newRow <= 5 && selectedRow >= 6) {
              setState(() {
                // 成り
                board[newRow][newCol] = promotePiece(currentPiece);
              });
            }
          }
        }
      }
    }

    // 王手があるか判定
    if (isKingInCheck(isAllyTurn)) {
      isCheck = true;
    } else {
      isCheck = false;
    }

    // 現在の選択をリセット
    setState(() {
      // 棋譜に記録
      coordinatesHistory.add("${toKanjiNumeral(selectedRow + 1)}${selectedCol.toString()}${selectedPiece!.typeStr()}");
      print(coordinatesHistory);

      selectedPiece = null;
      selectedRow = -1;
      selectedCol = -1;
      validMoves = [];
    });

    // 詰んでいた場合ダイアログを表示
    if (isCheckMate(isAllyTurn)) {
      showDialog(
        barrierDismissible: false,
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Center(
              child: Column(
                children: [
                  Text(
                    "詰みです",
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
                      'ホーム',
                      style: TextStyle(color: ColorTable.primaryNavyColor),
                    ),
                  ),
                ),
              ),
              GestureDetector(
                onTap: () {
                  // ダイアログを閉じる
                  Navigator.pop(context);
                },
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(5),
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    color: ColorTable.primaryWhiteColor,
                    child: const Text(
                      '盤面を見る',
                      style: TextStyle(color: ColorTable.primaryNavyColor),
                    ),
                  ),
                ),
              ),
              GestureDetector(
                onTap: () {
                  // ゲームの初期化
                  resetGame();
                },
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(5),
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    color: ColorTable.primaryWhiteColor,
                    child: const Text(
                      '再挑戦',
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
    } else {
      // ターンチェンジ
      if (isAllyTurn) {
        turnChange();
      }
    }
  }

  // 手持ちの駒を取りどこに打つか決める
  void selectDropPosition(ShogiPiece piece) {
    if (isAllyTurn == piece.isAlly) {
      setState(() {
        isSelectingDropPosition = true;
        selectedPiece = piece;
      });
    }
  }

  // 王手をかけている駒があるかどうか
  // isEnemyKing == true なら味方の駒が相手に王手をかけているかチェック
  // isEnemyKing == false なら相手の駒が味方に王手をかけているかチェック
  bool isKingInCheck(bool isAllyTurn) {
    List<int> kingPosition = isAllyTurn ? enemyKingPosition : allyKingPosition;

    for (int i = 0; i < 9; i++) {
      for (int j = 0; j < 9; j++) {
        if (board[i][j] == null || board[i][j]!.isAlly != isAllyTurn) {
          continue;
        }

        List<List<int>> pieceValiedMoves = calculateRealValidMoves(i, j, board[i][j], false);

        if (pieceValiedMoves.any((move) => move[0] == kingPosition[0] && move[1] == kingPosition[1])) {
          return true;
        }
      }
    }

    return false;
  }

  // 詰み判定
  bool isCheckMate(bool isAllyTurn) {
    // 王手がかかっていない場合は処理しない
    if (!isKingInCheck(isAllyTurn)) {
      return false;
    }

    for (int i = 0; i < 9; i++) {
      for (int j = 0; j < 9; j++) {
        // 対象の王・玉の敵の駒は判定しない
        if (board[i][j] == null || board[i][j]!.isAlly == isAllyTurn) {
          continue;
        }

        // 王・玉の移動できる座標を計算
        List<List<int>> pieceValiedMoves = calculateRealValidMoves(i, j, board[i][j], true);

        // 移動できる座標が残っている場合は詰んでいない
        if (pieceValiedMoves.isNotEmpty) {
          return false;
        }
      }
    }

    return true;
  }

  // 初期化
  void resetGame() {
    Navigator.pop(context);

    _initializeBoard();

    setState(() {
      isCheck = false;
      piecesTakenByAlly.clear();
      piecesTakenByEnemy.clear();
      allyKingPosition = [8, 4];
      enemyKingPosition = [0, 4];
      coordinatesHistory.clear();
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
          GridView.builder(
            shrinkWrap: true,
            itemCount: piecesTakenByEnemy.length,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 8),
            itemBuilder: (context, index) => DeadPiece(
              imagePath: piecesTakenByEnemy[index].imagePath,
              onTap: () => selectDropPosition(piecesTakenByEnemy[index]),
            ),
          ),
          if (isCheck)
            Container(
              padding: const EdgeInsets.all(8.0),
              width: MediaQuery.of(context).size.width * 0.3,
              decoration: BoxDecoration(
                color: ColorTable.primaryNavyColor,
                borderRadius: BorderRadius.circular(15),
              ),
              child: const Text(
                "王手！！",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          GridView.builder(
            shrinkWrap: true,
            itemCount: 9 * 9,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 9),
            itemBuilder: (context, index) {
              int row = index ~/ 9;
              int col = index % 9;
              bool isSelected = row == selectedRow && col == selectedCol;
              bool isValidMove = false;
              bool isHoheiLineUpVertically = false;

              // 選択中の駒が移動可能な座標かどうか
              for (var position in validMoves) {
                if (position[0] == row && position[1] == col) {
                  isValidMove = true;
                }
              }

              // 二歩が起きうる座標かどうか
              if (selectedPiece != null && selectedPiece!.type == ShogiPieceType.hohei) {
                for (int i = 0; i < 9; i++) {
                  if (board[i][col] != null && board[i][col]!.type == ShogiPieceType.hohei && board[i][col]!.isAlly == selectedPiece!.isAlly) {
                    isHoheiLineUpVertically = true;
                  }
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
          GridView.builder(
            shrinkWrap: true,
            itemCount: piecesTakenByAlly.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 8),
            physics: const NeverScrollableScrollPhysics(),
            itemBuilder: (context, index) => DeadPiece(
              imagePath: piecesTakenByAlly[index].imagePath,
              onTap: () => selectDropPosition(piecesTakenByAlly[index]),
            ),
          ),
        ],
      ),
    );
  }

  // CPUの行動制御
  void cpuActionWithShogiAi() {
    // 詰んでいた場合ダイアログを表示
    if (isCheckMate(!isAllyTurn)) {
      showDialog(
        barrierDismissible: false,
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Center(
              child: Column(
                children: [
                  Text(
                    "詰みです",
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
                      'ホーム',
                      style: TextStyle(color: ColorTable.primaryNavyColor),
                    ),
                  ),
                ),
              ),
              GestureDetector(
                onTap: () {
                  // ダイアログを閉じる
                  Navigator.pop(context);
                },
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(5),
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    color: ColorTable.primaryWhiteColor,
                    child: const Text(
                      '盤面を見る',
                      style: TextStyle(color: ColorTable.primaryNavyColor),
                    ),
                  ),
                ),
              ),
              GestureDetector(
                onTap: () {
                  // ゲームの初期化
                  resetGame();

                  // ダイアログを閉じる
                  Navigator.pop(context);
                },
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(5),
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    color: ColorTable.primaryWhiteColor,
                    child: const Text(
                      '再挑戦',
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
    } else {
      // 選択できる手を取得
      List<List<Map<String, dynamic>>> candidatePices = enumerateAvailableActions(board, turnCount, isCheck);
      ShogiPiece derivedActionPiece;
      List<int> derivedActionPieceCoordinates;
      List<int> candidateMoves;
      var random = Random();

      // 駒群からランダムにひとつ駒を選ぶ
      int randomIndex = random.nextInt(candidatePices.length);
      derivedActionPiece = candidatePices[randomIndex][0]["piece"]; // 導き出された駒
      derivedActionPieceCoordinates = candidatePices[randomIndex][1]["coordinates"]; // 導き出された駒の座標

      // 相手の駒を取れる駒があるならそちらを優先

      // ピースを選択
      selectPiece(derivedActionPieceCoordinates[0], derivedActionPieceCoordinates[1]);

      // 王手状態の場合は最優先で王を逃す
      if (validMoves.isEmpty) {
        selectPiece(enemyKingPosition[0], enemyKingPosition[1]);
      }

      // 移動可能な座標からランダムにひとつ選ぶ
      randomIndex = random.nextInt(validMoves.length);
      candidateMoves = validMoves[randomIndex];

      // 移動実行
      movePiece(candidateMoves[0], candidateMoves[1]);

      // ターンチェンジ
      setState(() {
        isAllyTurn = !isAllyTurn;
      });
    }
  }
}
