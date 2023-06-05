import 'dart:ui';

import 'package:flame/camera.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flame_tiled/flame_tiled.dart';
import '../actors/the_boy.dart';
import '../assets.dart' as assets;
import '../objects/background.dart';
import '../objects/platform.dart';

class PlatformerGame extends FlameGame
    with HasKeyboardHandlerComponents, HasCollisionDetection {
  late final double mapWidth;
  late final double mapHeight;

  // final world = World();
  // late final CameraComponent cameraComponent;

  @override
  Future<void> onLoad() async {
    await images.loadAll(assets.sprites);

    final level = await TiledComponent.load("level1.tmx", Vector2.all(64));

    mapWidth = level.tileMap.map.width * level.tileMap.destTileSize.x;
    mapHeight = level.tileMap.map.height * level.tileMap.destTileSize.y;

    add(ParallaxBackground(size: Vector2(mapWidth, mapHeight)));
    add(level);

    spawnObjects(level.tileMap);

    final theBoy = TheBoy(
      position: Vector2(128, mapHeight - 64),
    );
    add(theBoy);

    // cameraComponent = CameraComponent(world: world);
    // addAll([cameraComponent, world]);
    //
    // world.add(cameraComponent);
    //
    //cameraComponent.viewport.add

    camera.viewport = FixedResolutionViewport(Vector2(1920, 1280));
    camera.zoom = 2;
    camera.followComponent(
      theBoy,
      worldBounds: Rect.fromLTWH(0, 0, mapWidth, mapHeight),
    );
  }

  @override
  Color backgroundColor() {
    return const Color.fromARGB(255, 69, 186, 230);
  }

  void spawnObjects(RenderableTiledMap tileMap) {
    final platforms = tileMap.getLayer<ObjectGroup>("Platforms");

    for (final platform in platforms!.objects) {
      add(
        Platform(
          Vector2(platform.x, platform.y),
          Vector2(platform.width, platform.height),
        ),
      );
    }
  }
}
