import 'package:flutter/material.dart';
import 'package:horizontal_scrolling_game/color_table.dart';
import 'package:horizontal_scrolling_game/flappy_paimon/flappy_paimon.dart';
import 'package:horizontal_scrolling_game/paimon_impact/paimon_impact.dart';
import 'package:horizontal_scrolling_game/tetris/tetris.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              "minasehiro games",
              style: TextStyle(
                fontSize: 12,
                letterSpacing: 2.0,
                color: ColorTable.primaryBlackColor,
              ),
            ),
            const Padding(
              padding: EdgeInsets.only(top: 5.0, bottom: 30.0),
              child: Divider(
                color: ColorTable.primaryBlackColor,
                indent: 50.0,
                endIndent: 50.0,
              ),
            ),
            GestureDetector(
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => const PaimonImpact()),
                );
              },
              child: Container(
                width: MediaQuery.of(context).size.width * 0.9,
                height: 50,
                margin: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: ColorTable.primaryRedColor,
                    width: 3.0,
                  ),
                ),
                child: const Center(
                  child: Text(
                    "Paimon Impact",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      letterSpacing: 2.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
            GestureDetector(
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => const FlappyPaimon()),
                );
              },
              child: Container(
                width: MediaQuery.of(context).size.width * 0.9,
                height: 50,
                margin: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: ColorTable.primaryBlueColor,
                    width: 3.0,
                  ),
                ),
                child: const Center(
                  child: Text(
                    "FLAPPY Paimon",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      letterSpacing: 2.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
            GestureDetector(
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => const Tetris()),
                );
              },
              child: Container(
                width: MediaQuery.of(context).size.width * 0.9,
                height: 50,
                margin: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: ColorTable.primaryGreenColor,
                    width: 3.0,
                  ),
                ),
                child: const Center(
                  child: Text(
                    "TETRIS with Genshin Impact",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      letterSpacing: 2.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
