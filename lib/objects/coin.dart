import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import '../game/game.dart';

import '../assets.dart' as assets;

class Coin extends SpriteAnimationComponent with HasGameRef<PlatformerGame> {
  late final SpriteAnimation spinAnimation;
  late final SpriteAnimation collectAnimation;

  Coin(Vector2 position)
      : super(
          position: position,
          size: Vector2.all(48),
        );

  @override
  Future<void> onLoad() async {
    spinAnimation = SpriteAnimation.fromFrameData(
      game.images.fromCache(assets.coinSprite),
      SpriteAnimationData.sequenced(
        amount: 4,
        textureSize: Vector2.all(16),
        stepTime: 0.12,
      ),
    );

    collectAnimation = SpriteAnimation.fromFrameData(
      game.images.fromCache(assets.coinSprite),
      SpriteAnimationData.range(
          start: 4,
          end: 7,
          amount: 8,
          textureSize: Vector2.all(16),
          stepTimes: List.filled(4, 0.12),
          loop: false),
    );

    animation = spinAnimation;

    final hitbox = RectangleHitbox()..collisionType = CollisionType.passive;
    add(hitbox);

    return super.onLoad();
  }

  void collect() {
    game.onCoinCollected();
    animation = collectAnimation;
    collectAnimation.onComplete = () => {removeFromParent()};
  }
}
