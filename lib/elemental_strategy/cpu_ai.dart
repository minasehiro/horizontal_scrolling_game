// CPU側の操作に関するメソッド群

// 行動優先度案:
/// 5pt 元素爆発を相手に撃つ
/// 5pt 元素スキルを相手に撃つ
/// 3pt 元素粒子を拾う
/// 1pt 相手の付近から逃げる

// 選択できる手を列挙する
// [{ "piece": ShogiPiece1, "coordinates": [0, 3] }, { "piece": ShogiPiece2, "coordinates": [1, 1] }]
List<List<Map<String, dynamic>>> enumerateAvailableActions(board) {
  List<List<Map<String, dynamic>>> ourPieces = []; // 自分たちの重要な駒と座標
  List<List<Map<String, dynamic>>> theirPieces = []; // 相手の重要な駒と座標

  // 全ての駒を取得し、重要度・敵味方で分ける
  // [{ "piece": ShogiPiece1, "coordinates": [0, 3], "type": ShogiPieceType.kinsho },
  // { "piece": ShogiPiece2, "coordinates": [1, 1], "type": ShogiPieceType.hisya }]
  for (int i = 0; i < 6; i++) {
    for (int j = 0; j < 6; j++) {
      if (board[i][j] == null) {
        continue;
      } else if (board[i][j].isAlly) {
        theirPieces.add(
          [
            {
              "piece": board[i][j],
            },
            {
              "coordinates": [i, j],
            },
          ],
        );
      } else {
        ourPieces.add(
          [
            {
              "piece": board[i][j],
            },
            {
              "coordinates": [i, j],
            },
          ],
        );
      }
    }
  }

  // 1ターンごとに動かす駒を切り替える
  return ourPieces;
}

/// 自陣の強駒をリスト化

/// それぞれ敵から取られる可能性があるか評価
/// 可能性がある駒を逃す手を作成し配列に追加

/// 相手の強駒をリスト化
/// それぞれ取得できる手があるか評価
/// あれば手を配列に追加

/// 自陣の弱駒をリスト化
/// それぞれ敵から取られる可能性があるか評価
/// 可能性がある駒を逃す手を作成し配列に追加

/// 相手の弱駒をリスト化
/// それぞれ取得できる手があるか評価
/// あれば手を配列に追加

/// 相手の弱駒をリスト化
/// それぞれ取得できる手があるか評価
/// あれば手を配列に追加

// 手を重要度でソートする
