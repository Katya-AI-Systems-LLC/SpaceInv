# SpaceInv Architecture Overview

This document describes the current architecture of the Space Invaders Flutter project and how it can evolve towards a more AI‑driven, extensible system.

## 1. High-Level Layout

- **Flutter application** (single codebase)
  - `lib/main.dart` – app entry, service initialization
  - `lib/game_state.dart` – core gameplay state
  - `lib/screens/` – UI screens (menu, game, game over, stats, achievements, campaign, hangar)
  - `lib/services/` – domain services (audio, stats, achievements, campaign, currency, upgrades, leaderboard, localization)
  - `lib/models/` – data models and enums
  - `lib/widgets/` – visual components (player, enemy, bullets, barriers, power-ups)

## 2. Core Game Loop and State

- **GameScreen** drives the loop:
  - schedules 60 FPS updates via `_startGameLoop()`
  - updates `GameState` (enemies, bullets, power-ups, particles)
  - delegates movement to `EnemyMovementController`
  - checks collisions in `collision_detection.dart`
  - calls `GameOverConditions` to decide win/lose
- **GameState** holds:
  - `Player`, `Enemy`, `Bullet`, `Particle`, `PowerUp`, `Barrier`
  - score, level, mode, timers, modifiers, combo system
  - meta-upgrades (lives, shield, drops, starting power) applied on init

## 3. Modes and Meta-Progression

- **Game modes** in `models/game_mode.dart`:
  - `classic`, `survival`, `hardcore`, `galacticRun`, `bossRush`
- **Galactic Run**:
  - `RunModifier` changes behaviour per run (fast enemies, bullet hell, rich drops, kamikaze swarm)
- **Boss Rush**:
  - only boss waves, increasing HP/size/speed
  - dedicated boss HP bar + intro banner
- **Campaign** (`CampaignService`, `CampaignMission`):
  - mission list with conditions (score/level/kills/mode)
  - progress saved in local storage
  - `CampaignScreen` to select and start missions
- **Meta-progression**:
  - `CurrencyService` – global credits for runs
  - `UpgradesService` (+ `UpgradeType`) – hangar upgrades affecting gameplay
  - `HangarScreen` – UI for spending credits and viewing levels

## 4. Services and Persistence Layer

- **StatisticsService** – aggregate stats per game and lifetime
- **AchievementsService** – unlocks achievements from stats + game end context
- **LeaderboardService** – local leaderboard with optional REST sync
- **OnlineLeaderboardClient / RestOnlineLeaderboardClient** – pluggable backend abstraction
- **LocalizationService** – minimal RU/EN map‑based i18n
- All persistent data uses `SharedPreferences` under the hood.

## 5. Visual and UX Layer

- Animated widgets:
  - `PlayerWidget` – thruster & shield aura
  - `EnemyWidget` – glow + boss crown
  - `BarrierWidget` – health‑based color & glow
  - `PowerUpWidget` – radial gradient orb with glow
- HUD extras:
  - boss HP bar, power‑up badges
  - mode/modifier labels, combo multiplier and banners
  - power‑up mini‑banners and mode‑specific prefixes

## 6. "AI Quantum Engine" – Extension Points

The current game is deterministic and client‑side only. To move towards an AI‑driven, multi‑service architecture ("AI Quantum Engine"), the following extension points are planned:

- **AI Director Service (future):**
  - receives telemetry from `StatisticsService` and live runs
  - adjusts difficulty, modifiers and boss patterns dynamically
  - can be powered by external LLM/agent via HTTP/WebSocket API
- **Content & Balance Service (future):**
  - maintains configuration for enemies, waves, drop tables
  - allows remote updates (A/B tests, experimental modes)
- **Web3 / Blockchain Bridges (future):**
  - optional adapters that mirror achievements or leaderboard entries to chains (e.g. Polkadot‑based or EVM‑compatible networks)
  - kept behind separate services so the core game remains offline‑friendly
- **MCP / Multi‑Agent Integrations (future):**
  - treat services (leaderboard, campaign, AI director, web3 adapters) as tools in a broader agent ecosystem
  - the game becomes one of many clients of the "AI Quantum Revolution" backend.

## 7. Platform Abstraction

Flutter already provides a unified UI layer across Android, iOS, Web, Windows, macOS and Linux. Platform‑specific concerns are kept outside `lib/`:

- `android/`, `ios/`, `macos/`, `linux/`, `windows/`, `web/` – stock Flutter runners
- deployment logic is described in `DEPLOYMENT.md` and additional docs in `docs/PLATFORM_SUPPORT.md`

The gameplay and services are platform‑agnostic by design, which makes it safe to plug future frontends (for example, a web3‑enabled launcher, or an AI‑driven campaign selector) on top of the same core without forking logic.
