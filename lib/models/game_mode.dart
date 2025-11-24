enum GameMode {
  classic,
  survival,
  hardcore,
  galacticRun,
  bossRush,
}

extension GameModeInfo on GameMode {
  String get label {
    switch (this) {
      case GameMode.classic:
        return 'Classic';
      case GameMode.survival:
        return 'Survival';
      case GameMode.hardcore:
        return 'Hardcore';
      case GameMode.galacticRun:
        return 'Galactic Run';
      case GameMode.bossRush:
        return 'Boss Rush';
    }
  }

  String get description {
    switch (this) {
      case GameMode.classic:
        return 'Balanced progression with bosses.';
      case GameMode.survival:
        return 'Endless waves until you die.';
      case GameMode.hardcore:
        return 'Faster enemies and only 1 life.';
      case GameMode.galacticRun:
        return 'Rogue run with random wave modifiers.';
      case GameMode.bossRush:
        return 'Chain of escalating boss fights.';
    }
  }
}
