import 'package:flame/components.dart';
import '../game/game.dart';

import '../assets.dart' as assets;

class Hud extends PositionComponent with HasGameRef<PlatformerGame> {
  Hud() {
    positionType = PositionType.viewport;
  }

  void onCoinsNumberUpdated(int total) {
    final coin = SpriteComponent.fromImage(
        game.images.fromCache(assets.hudSprite),
        position: Vector2((50 * total).toDouble(), 50),
        size: Vector2.all(48));
    add(coin);
  }
}
