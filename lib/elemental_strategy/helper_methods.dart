import 'dart:math';

import 'package:flutter/material.dart';

import '../color_table.dart';
import 'components/character.dart';
import 'components/element_particle.dart';
import '../constants.dart';

// 元素粒子の種類と発生位置を計算
Map<String, dynamic> buildElementalParticle(elements, rows, cols) {
  Random random = Random();
  ElementParticle derivedElement;
  List<int> derivedCoordinates;

  derivedElement = elements[random.nextInt(elements.length)];
  derivedCoordinates = [rows[random.nextInt(rows.length)], cols[random.nextInt(cols.length)]];

  return {
    "element": derivedElement,
    "coordinates": derivedCoordinates,
  };
}

// キャラクターが移動可能な座標を配列で返す
List<List<int>> calculateRawValidMoves(List<List<Character?>> field, int row, int col, Character? character) {
  if (character == null) {
    return [];
  }

  List<List<int>> candidateMoves = [];

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

    // フィールドから出た場合
    if (!isInField(newRow, newCol)) {
      continue;
    }

    // 対象の座標にキャラクターがいる
    if (field[newRow][newCol] != null) {
      continue;
    }

    candidateMoves.add([newRow, newCol]);
  }

  return candidateMoves;
}

// 元素スキル・元素爆発の攻撃範囲を座標の配列で返す
List<List<int>> calculateAttackRange(List<List<Character?>> field, int row, int col, List<List<int>> damageRange, Character character) {
  List<List<int>> attackRanges = [];

  for (var range in damageRange) {
    var newRow = row + range[0];
    var newCol = col + range[1];

    // フィールドから出た場合
    if (!isInField(newRow, newCol)) {
      continue;
    }

    // 対象の座標に味方キャラクターがいる
    if (field[newRow][newCol] != null && field[newRow][newCol]!.isAlly == character.isAlly) {
      continue;
    }

    attackRanges.add([newRow, newCol]);
  }

  return attackRanges;
}

// 対象の座標がフィールドにあるか
bool isInField(int row, int col) {
  return row >= 0 && row < 6 && col >= 0 && col < 6;
}

// 元素爆発を発動可能か
bool canLaunchElementalBurst(character, currentTurn) {
  if (character != null && character.elementEnergy == 100 && !character.burst.isCoolTime(character.turnLastTriggeredBurst, currentTurn)) {
    return true;
  }
  return false;
}

// 元素爆発を発動可能か
bool canLaunchElementalSkill(character, currentTurn) {
  if (character != null && !character.skill.isCoolTime(character.turnLastTriggeredSkill, currentTurn)) {
    return true;
  }
  return false;
}

Color elementColor(ElementType type) {
  switch (type) {
    case ElementType.pyro:
      return ColorTable.pyroColor;
    case ElementType.hydro:
      return ColorTable.hydroColor;
    case ElementType.anemo:
      return ColorTable.anemoColor;
    case ElementType.electro:
      return ColorTable.electroColor;
    case ElementType.dendro:
      return ColorTable.dendroColor;
    case ElementType.cryo:
      return ColorTable.cryoColor;
    case ElementType.geo:
      return ColorTable.geoColor;
    default:
      return ColorTable.pyroColor;
  }
}
