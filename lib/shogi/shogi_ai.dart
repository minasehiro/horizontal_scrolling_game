// CPU側の操作に関するメソッド群

// import
import 'package:horizontal_scrolling_game/shogi/components/piece.dart';

// 行動優先度:
/// 5pt 強駒が取られるのを防ぐ
/// 5pt 相手の強駒が取れる
/// 3pt 弱駒が取られるのを防ぐ
/// 3pt 相手の弱駒が取れる
/// 1pt 相手陣に近づける
/// 4pt 持ち駒を打つ（全体の駒の数が一定数を下回った場合）

// 選択できる手を列挙する
// [{ "piece": ShogiPiece1, "coordinates": [0, 3] }, { "piece": ShogiPiece2, "coordinates": [1, 1] }]
List<List<Map<String, dynamic>>> enumerateAvailableActions(board, turnCount, isCheck) {
  List<List<Map<String, dynamic>>> ourPreciousPieces = []; // 自分たちの重要な駒と座標
  List<List<Map<String, dynamic>>> ourNormalPieces = []; // 自分たちの普通の駒と座標
  List<List<Map<String, dynamic>>> theirPreciousPieces = []; // 相手の重要な駒と座標
  List<List<Map<String, dynamic>>> theirNormalPieces = []; // 相手の普通の駒と座標
  List<ShogiPieceType> preciousPieceTypes = [
    // 重要な駒の種類
    ShogiPieceType.ousho, // 王
    ShogiPieceType.gyokusho, // 玉
    ShogiPieceType.hisya, // 飛
    ShogiPieceType.promotedHisya, // 龍
    ShogiPieceType.kakugyo, // 角
    ShogiPieceType.promotedKakugyo, // 馬
    ShogiPieceType.kinsho, // 金
  ];

  // 全ての駒を取得し、重要度・敵味方で分ける
  // [{ "piece": ShogiPiece1, "coordinates": [0, 3], "type": ShogiPieceType.kinsho },
  // { "piece": ShogiPiece2, "coordinates": [1, 1], "type": ShogiPieceType.hisya }]
  for (int i = 0; i < 9; i++) {
    for (int j = 0; j < 9; j++) {
      if (board[i][j] == null) {
        continue;
      } else if (board[i][j].isAlly) {
        if (preciousPieceTypes.contains(board[i][j].type)) {
          theirPreciousPieces.add(
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
          theirNormalPieces.add(
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
      } else {
        if (preciousPieceTypes.contains(board[i][j].type)) {
          ourPreciousPieces.add(
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
          ourNormalPieces.add(
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
  }

  if (isCheck) {
    // 王手状態なら全ての駒を行動対象にする
    return ourPreciousPieces + ourNormalPieces;
  } else {
    // 1ターンごとに動かす駒を切り替える
    return turnCount.isEven ? ourPreciousPieces : ourNormalPieces;
  }
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
