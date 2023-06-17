import 'package:flutter/material.dart';
import 'package:horizontal_scrolling_game/shogi/components/dead_piece.dart';
import 'package:horizontal_scrolling_game/shogi/components/piece.dart';
import 'package:horizontal_scrolling_game/shogi/components/square.dart';
import 'package:horizontal_scrolling_game/shogi/helper_methods.dart';

// TODO: 二歩の禁止
// TODO: 成り

class Shogi extends StatefulWidget {
  const Shogi({super.key});

  @override
  State<Shogi> createState() => _ShogiState();
}

class _ShogiState extends State<Shogi> {
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

  @override
  void initState() {
    super.initState();

    _initializeBoard();
  }

  // 盤面の初期化
  void _initializeBoard() {
    List<List<ShogiPiece?>> newBoard = List.generate(9, (index) => List.generate(9, (index) => null));

    // validMoves のテスト用
    // newBoard[4][4] = ShogiPiece(type: ShogiPieceType.kakugyo, isally: true, imagePath: "lib/assets/images/shogi/up_kakugyo.png");

    for (int i = 0; i < 9; i++) {
      // 敵陣
      newBoard[0][0] = ShogiPiece(type: ShogiPieceType.kyousya, isally: false, imagePath: "lib/assets/images/shogi/down_kyousya.png");
      newBoard[0][1] = ShogiPiece(type: ShogiPieceType.keima, isally: false, imagePath: "lib/assets/images/shogi/down_keima.png");
      newBoard[0][2] = ShogiPiece(type: ShogiPieceType.ginsho, isally: false, imagePath: "lib/assets/images/shogi/down_ginsho.png");
      newBoard[0][3] = ShogiPiece(type: ShogiPieceType.kinsho, isally: false, imagePath: "lib/assets/images/shogi/down_kinsho.png");
      newBoard[0][4] = ShogiPiece(type: ShogiPieceType.ousho, isally: false, imagePath: "lib/assets/images/shogi/down_ousho.png");
      newBoard[0][5] = ShogiPiece(type: ShogiPieceType.kinsho, isally: false, imagePath: "lib/assets/images/shogi/down_kinsho.png");
      newBoard[0][6] = ShogiPiece(type: ShogiPieceType.ginsho, isally: false, imagePath: "lib/assets/images/shogi/down_ginsho.png");
      newBoard[0][7] = ShogiPiece(type: ShogiPieceType.keima, isally: false, imagePath: "lib/assets/images/shogi/down_keima.png");
      newBoard[0][8] = ShogiPiece(type: ShogiPieceType.kyousya, isally: false, imagePath: "lib/assets/images/shogi/down_kyousya.png");
      newBoard[1][1] = ShogiPiece(type: ShogiPieceType.hisya, isally: false, imagePath: "lib/assets/images/shogi/down_hisya.png");
      newBoard[1][7] = ShogiPiece(type: ShogiPieceType.kakugyo, isally: false, imagePath: "lib/assets/images/shogi/down_kakugyo.png");
      newBoard[2][i] = ShogiPiece(type: ShogiPieceType.hohei, isally: false, imagePath: "lib/assets/images/shogi/down_hohei.png");

      // 自陣
      newBoard[6][i] = ShogiPiece(type: ShogiPieceType.hohei, isally: true, imagePath: "lib/assets/images/shogi/up_hohei.png");
      newBoard[7][1] = ShogiPiece(type: ShogiPieceType.kakugyo, isally: true, imagePath: "lib/assets/images/shogi/up_kakugyo.png");
      newBoard[7][7] = ShogiPiece(type: ShogiPieceType.hisya, isally: true, imagePath: "lib/assets/images/shogi/up_hisya.png");
      newBoard[8][0] = ShogiPiece(type: ShogiPieceType.kyousya, isally: true, imagePath: "lib/assets/images/shogi/up_kyousya.png");
      newBoard[8][1] = ShogiPiece(type: ShogiPieceType.keima, isally: true, imagePath: "lib/assets/images/shogi/up_keima.png");
      newBoard[8][2] = ShogiPiece(type: ShogiPieceType.ginsho, isally: true, imagePath: "lib/assets/images/shogi/up_ginsho.png");
      newBoard[8][3] = ShogiPiece(type: ShogiPieceType.kinsho, isally: true, imagePath: "lib/assets/images/shogi/up_kinsho.png");
      newBoard[8][4] = ShogiPiece(type: ShogiPieceType.gyokusho, isally: true, imagePath: "lib/assets/images/shogi/up_gyokusho.png");
      newBoard[8][5] = ShogiPiece(type: ShogiPieceType.kinsho, isally: true, imagePath: "lib/assets/images/shogi/up_kinsho.png");
      newBoard[8][6] = ShogiPiece(type: ShogiPieceType.ginsho, isally: true, imagePath: "lib/assets/images/shogi/up_ginsho.png");
      newBoard[8][7] = ShogiPiece(type: ShogiPieceType.keima, isally: true, imagePath: "lib/assets/images/shogi/up_keima.png");
      newBoard[8][8] = ShogiPiece(type: ShogiPieceType.kyousya, isally: true, imagePath: "lib/assets/images/shogi/up_kyousya.png");
    }

    board = newBoard;
  }

  // ピースを選択する
  void selectPiece(int row, int col) {
    setState(() {
      // 駒を選択していない状態から駒を選択した時
      if (selectedPiece == null && board[row][col] != null) {
        if (board[row][col]!.isally == isAllyTurn) {
          selectedPiece = board[row][col];
          selectedRow = row;
          selectedCol = col;
        }
        // 駒を選択している状態で自陣の他の駒を選択した時
      } else if (board[row][col] != null && board[row][col]!.isally == selectedPiece!.isally) {
        selectedPiece = board[row][col];
        selectedRow = row;
        selectedCol = col;
        // 移動可能な座標を選択した時
      } else if (selectedPiece != null && validMoves.any((coordinate) => coordinate[0] == row && coordinate[1] == col)) {
        movePiece(row, col);
        // 持ち駒を空き座標に打った時
      } else if (isSelectingDropPosition && board[row][col] == null) {
        // 空き座標にセット
        board[row][col] = selectedPiece;

        // 持ち駒から削除
        if (selectedPiece!.isally) {
          piecesTakenByAlly.remove(selectedPiece);
        } else {
          piecesTakenByEnemy.remove(selectedPiece);
        }

        // 現在の選択をリセット
        selectedPiece = null;
        selectedRow = -1;
        selectedCol = -1;
        validMoves = [];
        isSelectingDropPosition = false;

        // ターンチェンジ
        isAllyTurn = !isAllyTurn;
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
      currentKingPosition = piece.isally ? allyKingPosition : enemyKingPosition;

      if (piece.isally) {
        allyKingPosition = [candidateRow, candidateCol];
      } else {
        enemyKingPosition = [candidateRow, candidateCol];
      }
    }

    board[candidateRow][candidateCol] = piece;
    board[currentRow][currentCol] = null;

    bool isCheck = isKingInCheck(!piece.isally); // 移動先の位置で王手をかけられるかチェック

    board[currentRow][currentCol] = piece; // 駒の位置をもとに戻す
    board[candidateRow][candidateCol] = originalDestinationPiece; // 移動先の座標に元の駒を戻す

    // 王将の位置情報を元に戻す
    if (piece.type == ShogiPieceType.ousho || piece.type == ShogiPieceType.gyokusho) {
      if (piece.isally) {
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
    int direction = piece.isally ? -1 : 1;

    switch (piece.type) {
      case ShogiPieceType.hohei: // 歩兵
        var newRow = row + direction;

        // 盤面から出ていない
        if (isInBoard(newRow, col)) {
          // 空の座標か、敵の座標だった場合
          if (board[newRow][col] == null || board[newRow][col]!.isally != piece.isally) {
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
              if (board[newRow][newCol]!.isally != piece.isally) {
                candidateMoves.add([newRow, newCol]);
              }
              break;
            }

            candidateMoves.add([newRow, newCol]);
            i++;
          }
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
              if (board[newRow][newCol]!.isally != piece.isally) {
                candidateMoves.add([newRow, newCol]);
              }
              break;
            }

            candidateMoves.add([newRow, newCol]);
            i++;
          }
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
              if (board[newRow][col]!.isally != piece.isally) {
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
            if (board[newRow][newCol]!.isally != piece.isally) {
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
            if (board[newRow][newCol]!.isally != piece.isally) {
              candidateMoves.add([newRow, newCol]);
            }
            continue;
          }

          candidateMoves.add([newRow, newCol]);
        }

        break;
      case ShogiPieceType.kinsho: // 金将
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
            if (board[newRow][newCol]!.isally != piece.isally) {
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
            if (board[newRow][newCol]!.isally != piece.isally) {
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
  void movePiece(int newRow, int newCol) {
    if (board[newRow][newCol] != null) {
      var capturedPiece = board[newRow][newCol];

      // 駒の取得
      if (capturedPiece!.isally) {
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

    if (isKingInCheck(isAllyTurn)) {
      isCheck = true;
    } else {
      isCheck = false;
    }

    // 現在の選択をリセット
    setState(() {
      selectedPiece = null;
      selectedRow = -1;
      selectedCol = -1;
      validMoves = [];
    });

    if (isCheckMate(isAllyTurn)) {
      showDialog(
        context: context,
        builder: (cntext) => AlertDialog(
          title: const Text("詰みです"),
          actions: [
            TextButton(
              onPressed: resetGame,
              child: const Text("もう一度"),
            ),
          ],
        ),
      );
    }

    // ターンチェンジ
    isAllyTurn = !isAllyTurn;
  }

  // 手持ちの駒を取りどこに打つか決める
  void selectDropPosition(ShogiPiece piece) {
    if (isAllyTurn == piece.isally) {
      setState(() {
        isSelectingDropPosition = true;
        selectedPiece = piece;
      });
    }
  }

  // 駒を打つ
  void dropPiece() {}

  // 王手をかけている駒があるかどうか
  // isEnemyKing == true なら味方の駒が相手に王手をかけているかチェック
  // isEnemyKing == false なら相手の駒が味方に王手をかけているかチェック
  bool isKingInCheck(bool isEnemyKing) {
    List<int> kingPosition = isEnemyKing ? enemyKingPosition : allyKingPosition;

    for (int i = 0; i < 9; i++) {
      for (int j = 0; j < 9; j++) {
        if (board[i][j] == null || board[i][j]!.isally != isEnemyKing) {
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
  bool isCheckMate(bool isEnemyKing) {
    // 王手をかけられていない場合は処理しない
    if (isKingInCheck(!isEnemyKing)) {
      return false;
    }

    for (int i = 0; i < 9; i++) {
      for (int j = 0; j < 9; j++) {
        // 対象の王・玉の味方の駒は判定しない
        if (board[i][j] == null || board[i][j]!.isally == isEnemyKing) {
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
            child: GridView.builder(
              itemCount: piecesTakenByEnemy.length,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 8),
              itemBuilder: (context, index) => DeadPiece(
                imagePath: piecesTakenByEnemy[index].imagePath,
                onTap: () => selectDropPosition(piecesTakenByEnemy[index]),
              ),
            ),
          ),
          Text(isCheck ? "王手！！" : ""),
          Expanded(
            flex: 4,
            child: GridView.builder(
              itemCount: 9 * 9,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 9),
              itemBuilder: (context, index) {
                int row = index ~/ 9;
                int col = index % 9;
                bool isSelected = row == selectedRow && col == selectedCol;
                bool isValidMove = false;

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
                );
              },
            ),
          ),
          Expanded(
            flex: 2,
            child: GridView.builder(
              itemCount: piecesTakenByAlly.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 8),
              physics: const NeverScrollableScrollPhysics(),
              itemBuilder: (context, index) => DeadPiece(
                imagePath: piecesTakenByAlly[index].imagePath,
                onTap: () => selectDropPosition(piecesTakenByAlly[index]),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
