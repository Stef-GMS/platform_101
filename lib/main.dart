import 'package:flame/game.dart';
import 'package:flutter/widgets.dart';
import '../game/game.dart';

void main() {
  runApp(
    const GameWidget<PlatformerGame>.controlled(
      gameFactory: PlatformerGame.new,
    ),
  );
}
