import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter/services.dart';

import '../assets.dart' as assets;
import '../game/game.dart';
import '../objects/platform.dart';

class TheBoy extends SpriteAnimationComponent
    with KeyboardHandler, CollisionCallbacks, HasGameRef<PlatformerGame> {
  final double _moveSpeed = 300; // Max player's move speed

  int _horizontalDirection = 0; // Current direction the player is facing
  final Vector2 _velocity = Vector2.zero(); // Current player's speed

  final double _gravity = 15; // How fast The Boy gets pull down
  final double _jumpSpeed = 500; // How high The Boy jumps
  final double _maxGravitySpeed =
      300; // Max speed The Boy can have when falling

  bool _hasJumped = false;

  Component? _standingOn; // The component The Boy is currently standing on
  final Vector2 up = Vector2(0,
      -1); // Up direction vector we're gonna use to determine if The Boy is on the ground
  final Vector2 down = Vector2(0,
      1); // Down direction vector we're gonna use to determine if The Boy hit the platform above

  late final SpriteAnimation _runAnimation;
  late final SpriteAnimation _idleAnimation;
  late final SpriteAnimation _jumpAnimation;
  late final SpriteAnimation _fallAnimation;

  TheBoy({
    required super.position, // Position on the screen
  }) : super(
            size: Vector2.all(48), // Size of the component
            anchor: Anchor.bottomCenter //
            );

  @override
  Future<void> onLoad() async {
    _idleAnimation = SpriteAnimation.fromFrameData(
      game.images.fromCache(assets.theBoySprite),
      SpriteAnimationData.sequenced(
        amount:
            1, // For now we only need idle animation, so we load only 1 frame
        textureSize:
            Vector2.all(20), // Size of a single sprite in the sprite sheet
        stepTime:
            0.12, // Time between frames, since it's a single frame not that important
      ),
    );

    _runAnimation = SpriteAnimation.fromFrameData(
      game.images.fromCache(assets.theBoySprite),
      SpriteAnimationData.sequenced(
        amount: 4,
        textureSize: Vector2.all(20),
        stepTime: 0.12,
      ),
    );

    _jumpAnimation = SpriteAnimation.fromFrameData(
      game.images.fromCache(assets.theBoySprite),
      SpriteAnimationData.range(
        start: 4,
        end: 4,
        amount: 6,
        textureSize: Vector2.all(20),
        stepTimes: [0.12],
      ),
    );

    _fallAnimation = SpriteAnimation.fromFrameData(
      game.images.fromCache(assets.theBoySprite),
      SpriteAnimationData.range(
        start: 5,
        end: 5,
        amount: 6,
        textureSize: Vector2.all(20),
        stepTimes: [0.12],
      ),
    );

    animation = _idleAnimation;

    add(CircleHitbox());
  }

  @override
  bool onKeyEvent(RawKeyEvent event, Set<LogicalKeyboardKey> keysPressed) {
    _horizontalDirection = 0;
    _horizontalDirection += (keysPressed.contains(LogicalKeyboardKey.keyA) ||
            keysPressed.contains(LogicalKeyboardKey.arrowLeft))
        ? -1
        : 0;
    _horizontalDirection += (keysPressed.contains(LogicalKeyboardKey.keyD) ||
            keysPressed.contains(LogicalKeyboardKey.arrowRight))
        ? 1
        : 0;

    _hasJumped = keysPressed.contains(LogicalKeyboardKey.keyW) ||
        keysPressed.contains(LogicalKeyboardKey.arrowUp);

    return true;
  }

  @override
  void update(double dt) {
    super.update(dt);

    if (doesReachLeftEdge() || doesReachRightEdge()) {
      _velocity.x = 0;
    } else {
      _velocity.x = _horizontalDirection * _moveSpeed;
    }

    _velocity.y += _gravity;

    if (_hasJumped) {
      if (_standingOn != null) {
        _velocity.y = -_jumpSpeed;
      }
      _hasJumped = false;
    }

    _velocity.y = _velocity.y.clamp(-_jumpSpeed, _maxGravitySpeed);

    position += _velocity * dt;

    // check if the current direction (the arrow the user is pressing)
    // is different from the direction of the sprite, then we flip the
    // sprite along the horizontal axis.
    if ((_horizontalDirection < 0 && scale.x > 0) ||
        (_horizontalDirection > 0 && scale.x < 0)) {
      flipHorizontally();
    }

    updateAnimation();
  }

  void updateAnimation() {
    if (_standingOn != null) {
      if (_horizontalDirection == 0) {
        animation = _idleAnimation;
      } else {
        animation = _runAnimation;
      }
    } else {
      if (_velocity.y > 0) {
        animation = _fallAnimation;
      } else {
        animation = _jumpAnimation;
      }
    }
  }

  bool doesReachLeftEdge() {
    return position.x <= size.x / 2 && _horizontalDirection < 0;
  }

  bool doesReachRightEdge() {
    return position.x >= game.mapWidth - size.x / 2 && _horizontalDirection > 0;
  }

  @override
  void onCollision(Set<Vector2> intersectionPoints, PositionComponent other) {
    if (other is Platform) {
      if (intersectionPoints.length == 2) {
        //calculate the middle point between the points of intersection
        final mid = (intersectionPoints.elementAt(0) +
                intersectionPoints.elementAt(1)) /
            2;

        // the direction The Boy moves towards the platform
        final collisionVector = absoluteCenter - mid;

        // using the radius (size.x / 2) and length of collisionVector we
        // calculate how deep the circle hitbox is penetrating the rectangular platform.
        double penetrationDepth = (size.x / 2) - collisionVector.length;

        // normalize the vector to have just the direction of the collision
        collisionVector.normalize();

        // check if The Boy is colliding with the platform below him
        // and save the reference to that component.
        if (up.dot(collisionVector) > 0.9) {
          _standingOn = other;
        } else if (down.dot(collisionVector) > 0.9) {
          _velocity.y += _gravity;
        }

        // update the player’s position by penetrationDepth multiplied by
        // the normalized vector to keep the direction
        position += collisionVector.scaled(penetrationDepth);
      }
    }

    super.onCollision(intersectionPoints, other);
  }

  @override
  void onCollisionEnd(PositionComponent other) {
    if (other == _standingOn) {
      _standingOn = null;
    }
    super.onCollisionEnd(other);
  }
}
