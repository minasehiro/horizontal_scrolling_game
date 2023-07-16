import 'dart:math';

import 'package:flutter/material.dart';
import 'components/character.dart';

import '../color_table.dart';
import 'components/element_particle.dart';
import '../constants.dart';
import 'components/elemental_burst.dart';
import 'components/elemental_skill.dart';

// キャラクターを生成
Character buildCharacter(type, xCoordinate, yCoordinate) {
  switch (type) {
    case CharacterType.kaedeharaKazuha:
      return Character(
        type: CharacterType.kaedeharaKazuha,
        elementType: ElementType.anemo,
        isAlly: true,
        imagePath: "lib/assets/images/elemental_strategy/characters/up_kaedeharaKazuha.png",
        elementEnergy: 0,
        hitPoint: 100,
        currentRow: xCoordinate,
        currentCol: yCoordinate,
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
        lastTriggeredSkill: 0,
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
        lastTriggeredBurst: 0,
      );
    case CharacterType.zhongli:
      return Character(
        type: CharacterType.zhongli,
        elementType: ElementType.geo,
        isAlly: true,
        imagePath: "lib/assets/images/elemental_strategy/characters/up_zhongli.png",
        elementEnergy: 0,
        hitPoint: 100,
        currentRow: xCoordinate,
        currentCol: yCoordinate,
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
        lastTriggeredSkill: 0,
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
        lastTriggeredBurst: 0,
      );
    case CharacterType.kamisatoAyaka:
      return Character(
        type: CharacterType.kamisatoAyaka,
        elementType: ElementType.cryo,
        isAlly: true,
        imagePath: "lib/assets/images/elemental_strategy/characters/up_kamisatoAyaka.png",
        elementEnergy: 0,
        hitPoint: 100,
        currentRow: xCoordinate,
        currentCol: yCoordinate,
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
        lastTriggeredSkill: 0,
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
        lastTriggeredBurst: 0,
      );
    case CharacterType.nahida:
      return Character(
        type: CharacterType.nahida,
        elementType: ElementType.dendro,
        isAlly: true,
        imagePath: "lib/assets/images/elemental_strategy/characters/up_nahida.png",
        elementEnergy: 0,
        hitPoint: 100,
        currentRow: xCoordinate,
        currentCol: yCoordinate,
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
        lastTriggeredSkill: 0,
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
        lastTriggeredBurst: 0,
      );
    case CharacterType.yaeMiko:
      return Character(
        type: CharacterType.yaeMiko,
        elementType: ElementType.electro,
        isAlly: true,
        imagePath: "lib/assets/images/elemental_strategy/characters/up_yaeMiko.png",
        elementEnergy: 0,
        hitPoint: 100,
        currentRow: xCoordinate,
        currentCol: yCoordinate,
        skill: ElementalSkill(
          name: "野干役呪・殺生櫻",
          voice: "具現化せよ。",
          elementType: ElementType.electro,
          damage: 0,
          damageRange: [],
          coolTime: 1,
          numberOfParticlesGenerated: 0,
        ),
        lastTriggeredSkill: 0,
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
        lastTriggeredBurst: 0,
      );
    case CharacterType.xiao:
      return Character(
        type: CharacterType.xiao,
        elementType: ElementType.anemo,
        isAlly: true,
        imagePath: "lib/assets/images/elemental_strategy/characters/up_xiao.png",
        elementEnergy: 0,
        hitPoint: 100,
        currentRow: xCoordinate,
        currentCol: yCoordinate,
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
        lastTriggeredSkill: 0,
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
        lastTriggeredBurst: 0,
      );
    case CharacterType.xingqiu:
      return Character(
        type: CharacterType.xingqiu,
        elementType: ElementType.hydro,
        isAlly: true,
        imagePath: "lib/assets/images/elemental_strategy/characters/up_xingqiu.png",
        elementEnergy: 0,
        hitPoint: 100,
        currentRow: xCoordinate,
        currentCol: yCoordinate,
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
        lastTriggeredSkill: 0,
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
        lastTriggeredBurst: 0,
      );
    case CharacterType.yanfei:
      return Character(
        type: CharacterType.yanfei,
        elementType: ElementType.pyro,
        isAlly: true,
        imagePath: "lib/assets/images/elemental_strategy/characters/up_yanfei.png",
        elementEnergy: 0,
        hitPoint: 100,
        currentRow: xCoordinate,
        currentCol: yCoordinate,
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
        lastTriggeredSkill: 0,
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
        lastTriggeredBurst: 0,
      );
    default:
      return Character(
        type: CharacterType.kaedeharaKazuha,
        elementType: ElementType.anemo,
        isAlly: true,
        imagePath: "lib/assets/images/elemental_strategy/characters/up_kaedeharaKazuha.png",
        elementEnergy: 0,
        hitPoint: 100,
        currentRow: xCoordinate,
        currentCol: yCoordinate,
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
        lastTriggeredSkill: 0,
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
        lastTriggeredBurst: 0,
      );
  }
}

// 元素粒子の種類と発生位置を計算
Map<String, dynamic> buildElementalParticle(elements) {
  Random random = Random();
  ElementParticle derivedElement;
  List<double> derivedCoordinates;

  derivedElement = elements[random.nextInt(elements.length)];
  derivedCoordinates = [random.nextInt(2) - random.nextDouble(), random.nextInt(2) - random.nextDouble()];

  return {
    "element": derivedElement,
    "coordinates": derivedCoordinates,
  };
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
