import 'dart:async';
import 'package:flutter/material.dart';
import 'package:horizontal_scrolling_game/flappy_paimon/barrier.dart';
import 'package:horizontal_scrolling_game/home_page.dart';
import 'package:horizontal_scrolling_game/color_table.dart';
import 'package:horizontal_scrolling_game/flappy_paimon/paimon.dart';
import 'package:horizontal_scrolling_game/flappy_paimon/game_banner.dart';

class FlappyPaimon extends StatefulWidget {
  const FlappyPaimon({super.key});

  @override
  State<FlappyPaimon> createState() => _FlappyPaimonState();
}

class _FlappyPaimonState extends State<FlappyPaimon> {
  // paimon が持つ情報
  static double paimonY = 0;

  double initPos = paimonY;
  double height = 1;
  double time = 0;
  double gravity = -3.9; // 重力
  double jumpVelocity = 1.5; // ジャンプの速さ（強さ）
  double paimonWidth = 0.15;
  double paimonHeight = 0.15;

  // ゲーム設定
  bool isGameStarted = false;
  final int gameSpeed = 50; // スコアが高まるごとにスピードを上げていく説
  final double scoreRangeStartXPoint = -0.05;
  final double scoreRangeEndXPoint = -0.1;

  // 成績
  int currentScore = 0;
  int bestScore = 0;

  // 障害物設定
  static List<double> barrierX = [2, 2 + 1.5];
  static double barrierWidth = 0.25;
  List<List<double>> barrierHeight = [
    [0.6, 0.4],
    [0.4, 0.6],
  ];

  void startGame() {
    isGameStarted = true;
    Timer.periodic(Duration(milliseconds: gameSpeed), (timer) {
      // 擬似的なジャンプの計算（放物線を描く）
      height = gravity * time * time + jumpVelocity * time;

      setState(() {
        // FLAPPY BIRD Ver.
        paimonY = initPos - height;
      });

      // 画面外に出るとゲームオーバー
      if (paimonIsDead()) {
        timer.cancel();
        _showDialog();
      }

      // 自動スクロール
      scrollBackground();

      time += 0.05;
    });
  }

  // 背景のスクロールを感じさせるためにバリアを右から左に動かす
  void scrollBackground() {
    for (int i = 0; i < barrierX.length; i++) {
      setState(() {
        barrierX[i] -= 0.05;
      });

      // スコア計算
      // X座標が -0.05 ~ -0.1 の間を通過すればパイモンが通過したとみなす
      // -0.05 ~ -0.1 とは 画面真ん中から少し左の位置
      if (barrierX[i] < scoreRangeStartXPoint && barrierX[i] > scoreRangeEndXPoint) {
        setState(() {
          currentScore += 1;
        });
      }

      // 左に消えていったバリアをループさせる
      if (barrierX[i] < -1.5) {
        barrierX[i] += 3;
      }
    }
  }

  void resetGame() {
    Navigator.pop(context); // ダイアログを消す

    // 各種データをリセット
    setState(() {
      // FLAPPY BIRD Ver.
      paimonY = 0;

      // Horizontal Scrolling Ver.
      // paimonY = 0.85;

      isGameStarted = false;
      time = 0;
      initPos = paimonY;
      barrierX = [2, 2 + 1.5];
      if (currentScore > bestScore) {
        bestScore = currentScore;
      }
      currentScore = 0;
    });
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

    // 障害物にあたった場合
    for (int i = 0; i < barrierX.length; i++) {
      if (barrierX[i] <= paimonWidth && barrierX[i] + barrierWidth >= -paimonWidth && (paimonY <= -1 + barrierHeight[i][0] || paimonY + paimonHeight >= 1 - barrierHeight[i][1])) {
        return true;
      }
    }

    return false;
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
                      GameBanner(isGameStarted: isGameStarted),
                      Paimon(
                        paimonY: paimonY,
                        paimonWidth: paimonWidth,
                        paimonHeight: paimonHeight,
                      ),
                      Barrier(
                        barrierX: barrierX[0],
                        barrierWidth: barrierWidth,
                        barrierHeight: barrierHeight[0][0],
                        isThisBottomBarrier: false,
                      ),
                      Barrier(
                        barrierX: barrierX[0],
                        barrierWidth: barrierWidth,
                        barrierHeight: barrierHeight[0][1],
                        isThisBottomBarrier: true,
                      ),
                      Barrier(
                        barrierX: barrierX[1],
                        barrierWidth: barrierWidth,
                        barrierHeight: barrierHeight[1][0],
                        isThisBottomBarrier: false,
                      ),
                      Barrier(
                        barrierX: barrierX[1],
                        barrierWidth: barrierWidth,
                        barrierHeight: barrierHeight[1][1],
                        isThisBottomBarrier: true,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Expanded(
              flex: 1,
              child: Container(
                color: ColorTable.primaryGreenColor,
                width: MediaQuery.of(context).size.width,
              ),
            ),
            Expanded(
              flex: 8,
              child: Container(
                color: ColorTable.primaryNavyColor,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          'スコア',
                          style: TextStyle(
                            color: ColorTable.primaryWhiteColor,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          currentScore.toString(),
                          style: const TextStyle(
                            color: ColorTable.primaryWhiteColor,
                            fontSize: 24,
                          ),
                        ),
                      ],
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          'ベスト',
                          style: TextStyle(
                            color: ColorTable.primaryWhiteColor,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          bestScore.toString(),
                          style: const TextStyle(
                            color: ColorTable.primaryWhiteColor,
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
}
