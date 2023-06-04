import 'dart:math';
import 'dart:async';
import 'package:flutter/material.dart';

import 'package:horizontal_scrolling_game/color_table.dart';
import 'package:horizontal_scrolling_game/home_page.dart';
import 'package:horizontal_scrolling_game/tetris/piece.dart';
import 'package:horizontal_scrolling_game/tetris/pixel.dart';
import 'package:horizontal_scrolling_game/tetris/constants.dart';

// 15 × 10 のグリッドを配列として定義
List<List<Tetromino?>> gameBoard = List.generate(colLength, (i) {
  return List.generate(rowlength, (y) {
    return null;
  });
});

class Tetris extends StatefulWidget {
  const Tetris({super.key});

  @override
  State<Tetris> createState() => _TetrisState();
}

class _TetrisState extends State<Tetris> {
  Piece currentPiece = Piece(type: Tetromino.L); // 最初のピースを生成
  int currentScore = 0;
  bool isGameOver = false;
  bool isGameStarted = false;

  void startGame() {
    setState(() {
      isGameStarted = true;
    });

    // ピースを配置
    currentPiece.initializePiece();

    // ゲームスピード
    Duration frameRate = const Duration(milliseconds: 400);

    // ゲームループ起動
    gameLoop(frameRate);
  }

  // フレームレートに沿ってゲームループを起動する
  void gameLoop(Duration frameRate) {
    Timer.periodic(frameRate, (timer) {
      setState(() {
        // ピースがX方向に埋まっていれば消す
        clearLines();

        // 地面（他のピース）との衝突判定
        checkLanding();

        if (isGameOver) {
          timer.cancel();

          showGameOverDialog();
        }

        // ピースを下に落とす
        currentPiece.movePiece(MoveDirection.down);
      });
    });
  }

  // ピースがX方向に埋まっていれば消す
  void clearLines() {
    // 画面下から1行ずつ処理
    for (int row = colLength - 1; row >= 0; row--) {
      bool rowIsFull = true;

      // 画面左から1列ずつ処理
      for (int col = 0; col < rowlength; col++) {
        if (gameBoard[row][col] == null) {
          rowIsFull = false;
          break;
        }
      }

      // rowIsFull が true のままなら1列全て埋まっているので列を削除する
      if (rowIsFull) {
        for (int r = row; r > 0; r--) {
          // 1列ずつ下に下げる
          gameBoard[r] = List.from(gameBoard[r - 1]);
        }

        // 上に列を追加
        gameBoard[0] = List.generate(row, (index) => null);

        // スコアを上昇
        currentScore++;
      }
    }
  }

  // 地面やピースに衝突している場合、位置を固定し次のピースを用意する
  void checkLanding() {
    if (isLanded(MoveDirection.down)) {
      for (int i = 0; i < currentPiece.position.length; i++) {
        int row = (currentPiece.position[i] / rowlength).floor();
        int col = currentPiece.position[i] % rowlength;

        if (row >= 0 && col >= 0) {
          gameBoard[row][col] = currentPiece.type;
        }
      }

      buildNewPiece();
    }
  }

  // 地面（他のピース）との衝突判定
  bool isLanded(MoveDirection direction) {
    for (int i = 0; i < currentPiece.position.length; i++) {
      int row = (currentPiece.position[i] / rowlength).floor();
      int col = currentPiece.position[i] % rowlength;

      // ピースが次に移動する座標をセット
      if (direction == MoveDirection.left) {
        col -= 1;
      } else if (direction == MoveDirection.right) {
        col += 1;
      } else if (direction == MoveDirection.down) {
        row += 1;
      }

      // 地面に衝突しているか、左右画面外に出ている場合
      if (row >= colLength || col < 0 || col >= rowlength) {
        return true;
      }

      // 他のブロックと衝突している場合
      if (row >= 0 && gameBoard[row][col] != null) {
        return true;
      }
    }

    return false;
  }

  // ピースを用意
  void buildNewPiece() {
    Random rand = Random();

    // 形をランダムで決定
    Tetromino randomTetrominoType = Tetromino.values[rand.nextInt(Tetromino.values.length)];

    // ピースを生成
    currentPiece = Piece(type: randomTetrominoType);

    // ピースを配置
    currentPiece.initializePiece();

    if (checkGameOver()) {
      isGameOver = true;
    }
  }

  // ゲームオーバーの判定
  bool checkGameOver() {
    // 画面左から処理
    for (int col = 0; col < rowlength; col++) {
      // 一番上のグリッドが埋まっていれば
      if (gameBoard[0][col] != null) {
        return true;
      }
    }

    return false;
  }

  // ゲームオーバー時のダイアログ
  void showGameOverDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          backgroundColor: ColorTable.primaryNavyColor,
          title: Center(
            child: Column(
              children: [
                const Text(
                  'ゲームオーバー',
                  style: TextStyle(color: ColorTable.primaryWhiteColor),
                ),
                const SizedBox(height: 30),
                const Text(
                  'スコア',
                  style: TextStyle(
                    color: ColorTable.primaryWhiteColor,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  currentScore.toString(),
                  style: const TextStyle(
                    color: ColorTable.primaryWhiteColor,
                    fontSize: 24,
                  ),
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
              onTap: () {
                resetGame();

                Navigator.pop(context);
              },
              child: ClipRRect(
                borderRadius: BorderRadius.circular(5),
                child: Container(
                  padding: const EdgeInsets.all(10),
                  color: ColorTable.primaryWhiteColor,
                  child: const Text(
                    'もう一度挑戦する',
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

  // ゲームをリスタート
  void resetGame() {
    // 必要なデータを初期化
    setState(() {
      // 15 × 10 のグリッドを配列として定義
      gameBoard = List.generate(colLength, (i) {
        return List.generate(rowlength, (y) {
          return null;
        });
      });

      isGameOver = false;
      isGameStarted = false;
      currentScore = 0;

      // 最初に落とすピースを用意
      buildNewPiece();

      // ゲームスタート
      startGame();
    });
  }

  // ピースを左に移動
  void moveLeft() {
    if (!isLanded(MoveDirection.left)) {
      setState(() {
        currentPiece.movePiece(MoveDirection.left);
      });
    }
  }

  // ピースを回転
  void rotatePiece() {
    setState(() {
      currentPiece.rotatePiece();
    });
  }

  // ピースを右に移動
  void moveRight() {
    if (!isLanded(MoveDirection.right)) {
      setState(() {
        currentPiece.movePiece(MoveDirection.right);
      });
    }
  }

  // ピースを下に移動
  void moveDown() {
    if (!isLanded(MoveDirection.down)) {
      setState(() {
        currentPiece.movePiece(MoveDirection.down);
      });
    }
  }

  // UI
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        isGameStarted ? rotatePiece() : startGame();
      },
      // DragUpdate の感度が高すぎるので偶数の時だけ処理
      onVerticalDragUpdate: ((details) {
        if (details.delta.dy > 0 && details.delta.dy.floor().isEven) {
          moveDown();
        }
      }),
      // DragUpdate の感度が高すぎるので3の倍数の時だけ処理
      onHorizontalDragUpdate: ((details) {
        if (details.delta.dx > 0 && details.delta.dx.floor() % 3 == 0) {
          moveRight();
        } else if (details.delta.dx < 0 && details.delta.dx.floor() % 3 == 0) {
          moveLeft();
        }
      }),
      child: Scaffold(
        backgroundColor: ColorTable.primaryBlackColor,
        body: Column(
          children: [
            Expanded(
              flex: 20,
              child: GridView.builder(
                itemCount: rowlength * colLength,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: rowlength),
                itemBuilder: (context, index) {
                  int row = (index / rowlength).floor(); // X座標
                  int col = index % rowlength; // Y座標

                  // 移動中のピース
                  if (currentPiece.position.contains(index)) {
                    return Pixel(
                      color: Colors.yellow,
                      childStr: index.toString(),
                    );
                  }
                  // 衝突済みのピース
                  else if (gameBoard[row][col] != null) {
                    final Tetromino? tetrominoType = gameBoard[row][col];

                    return Pixel(
                      color: tetrominoColors[tetrominoType] ?? Colors.white,
                      childStr: "",
                    );
                  }
                  // 空いているグリッド
                  else {
                    return Pixel(
                      color: Colors.grey,
                      childStr: index.toString(),
                    );
                  }
                },
              ),
            ),
            Expanded(
              flex: 1,
              child: Padding(
                padding: const EdgeInsets.all(5.0),
                child: Text(
                  isGameStarted ? "Score: $currentScore" : "画面タップでスタート",
                  style: const TextStyle(
                    fontSize: 18,
                    color: ColorTable.primaryWhiteColor,
                  ),
                ),
              ),
            ),
            Expanded(
              flex: 4,
              child: Row(
                // mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: moveLeft,
                      child: Container(
                        height: double.infinity,
                        decoration: BoxDecoration(
                          border: Border(
                            top: BorderSide(
                              color: ColorTable.primaryWhiteColor.withOpacity(0.1),
                              width: 1,
                            ),
                          ),
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.arrow_back_ios,
                            color: ColorTable.primaryWhiteColor,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: rotatePiece,
                      child: Container(
                        height: double.infinity,
                        decoration: BoxDecoration(
                          border: Border(
                            top: BorderSide(
                              color: ColorTable.primaryWhiteColor.withOpacity(0.1),
                              width: 1,
                            ),
                            right: BorderSide(
                              color: ColorTable.primaryWhiteColor.withOpacity(0.1),
                              width: 1,
                            ),
                            left: BorderSide(
                              color: ColorTable.primaryWhiteColor.withOpacity(0.1),
                              width: 1,
                            ),
                          ),
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.rotate_right,
                            color: ColorTable.primaryWhiteColor,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: moveRight,
                      child: Container(
                        height: double.infinity,
                        decoration: BoxDecoration(
                          border: Border(
                            top: BorderSide(
                              color: ColorTable.primaryWhiteColor.withOpacity(0.1),
                              width: 1,
                            ),
                          ),
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.arrow_forward_ios,
                            color: ColorTable.primaryWhiteColor,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
