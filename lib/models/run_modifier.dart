enum RunModifier {
  fastEnemies,
  bulletHell,
  richDrops,
  kamikazeSwarm,
}

extension RunModifierInfo on RunModifier {
  String get label {
    switch (this) {
      case RunModifier.fastEnemies:
        return 'Fast Enemies';
      case RunModifier.bulletHell:
        return 'Bullet Hell';
      case RunModifier.richDrops:
        return 'Rich Drops';
      case RunModifier.kamikazeSwarm:
        return 'Kamikaze Swarm';
    }
  }

  String get description {
    switch (this) {
      case RunModifier.fastEnemies:
        return 'Enemies move faster than usual.';
      case RunModifier.bulletHell:
        return 'More and faster enemy bullets.';
      case RunModifier.richDrops:
        return 'Power-ups drop much more often.';
      case RunModifier.kamikazeSwarm:
        return 'Extra kamikaze enemies join the wave.';
    }
  }
}
