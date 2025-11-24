# Platform Support and Build Matrix

This document summarizes the current state of platform support for the Space Invaders Flutter project and how to build for each target.

> Detailed commands and deployment recipes are in `DEPLOYMENT.md`. This file provides a high‑level matrix and notes for future platforms.

## 1. Official Flutter Targets (Implemented)

| Platform  | Status    | Runner Folder | Build Command                      | Notes |
|----------|-----------|---------------|------------------------------------|-------|
| Android  | Supported | `android/`    | `flutter build apk` / `appbundle`  | Primary mobile target |
| iOS      | Supported | `ios/`        | `flutter build ios` (on macOS)     | Requires Xcode & Apple account |
| Web      | Supported | `web/`        | `flutter build web`                | Can be deployed to GitHub Pages/Firebase/etc. |
| Windows  | Supported | `windows/`    | `flutter build windows`            | Desktop runner using Win32/WinUI host |
| macOS    | Supported | `macos/`      | `flutter build macos`              | Desktop runner with Cocoa/AppKit host |
| Linux    | Supported | `linux/`      | `flutter build linux`              | Desktop runner (GTK) |

All of the above are wired through a shared Dart codebase in `lib/`. No platform‑specific game logic exists today.

## 2. Experimental / Planned Platforms

These platforms are **not** implemented yet, but can be explored as separate host projects around the same `lib/` code.

### 2.1 Windows UWP / WinUI

Flutter officially supports Windows desktop via a Win32/WinUI host. A pure UWP packaging layer would typically be done via:

- Bridging the generated `windows/` runner into MSIX packaging.
- Optionally creating a thin UWP shell that embeds the Flutter view or launches the desktop runner.

Status:

- No dedicated `winuwp/` folder is created to avoid fragmenting the project.
- Instead, UWP/MSIX packaging should be handled at the CI/CD and installer level.

### 2.2 Aurora OS / Other Linux‑Based Mobile OS

For exotic mobile OSes (Aurora, Sailfish, etc.):

- Flutter support depends on the underlying system having a supported engine build.
- A pragmatic path is to target **Linux desktop** build and run it under the corresponding environment/container.

Status:

- No dedicated `aurora/` folder yet.
- Future work may define an `aurora/` runner once a stable Flutter engine target exists.

### 2.3 Additional Frontends (Launchers, Web3 Clients)

Beyond native runners, the same game core can be:

- Embedded into custom launchers (Electron, Tauri, native hosts) via Flutter embedding.
- Wrapped into web3‑enabled dApps that talk to the game via IPC or WebSockets.

These are treated as **separate projects** that depend on this repository as a game engine package.

## 3. Build Profiles and CI

For each supported platform, recommended profiles are:

- **Debug:** development only, `flutter run` with hot reload.
- **Profile / Release:** performance testing and release builds (`flutter build <target> --release`).

CI examples (GitHub Actions) are documented in `DEPLOYMENT.md` and can be extended to:

- Build artifacts for Android, Web, and Desktop.
- Optionally publish Web build to GitHub Pages / another static host.

## 4. Next Steps

- Automate multi‑platform builds via CI pipelines per hosting provider.
- Add platform‑specific checklists in separate files if the project grows (e.g. `docs/PLATFORM_ANDROID.md`, `docs/PLATFORM_IOS.md`).
- Keep the game logic in `lib/` strictly platform‑agnostic so new frontends (UWP, Aurora, consoles, etc.) can reuse it without forks.
