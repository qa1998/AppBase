# Football Lineup Builder

Premium tactical squad builder module inside AppBase.

## Design system

| Token | Value |
|-------|--------|
| Background | `#0F1115` |
| Surface | `#161B22` |
| Green accent | `#00D26A` |
| Red accent | `#FF2D55` |
| Typography | SF Pro (system semibold/bold) |

## Screens

1. **Splash** — animated logo, brand, 2.2s → main tabs  
2. **Home** — greeting, recent lineups, create CTA, formation carousel, shortcuts  
3. **Lineup editor** — pitch, drag tokens, bench, segments (Formation / Players / Tactics), undo/redo/save  
4. **Formation picker** — bottom sheet grid with mini pitch + neon selection  
5. **Player picker** — search + position filters + rating cards  
6. **Tactical mode** — arrow/zone drawing overlay  
7. **Export** — preview card, poster/social templates, share sheet  

## Entry

`AppState.main` → `AppCoordinator.runMainFlow()` → **`FootballCoordinator`** (root).  
Không dùng `MainViewController` / ESTabBar 5 tab nữa.

App splash (~1s) → Football tab shell (**Lineups** · Matches · Settings).

**Lineups tab:** My Lineups list (filters, cards, FAB) → push Editor / Export.

**Settings:** Dark / Light mode — `ThemeManager` + `FootballPalette` light/dark colors.  
Tùy chọn splash Football: `FootballCoordinator(entryPoint: .splash)`.

## Code layout

```
AppBase/Presentation/Football/
  Theme/FootballPalette.swift
  Models/FootballModels.swift
  Store/LineupStore.swift
  Components/
  Splash/ Home/ Editor/ Formation/ Players/ Tactical/ Export/
  FootballCoordinator.swift
  FootballTabBarController.swift
```

## Run SwiftGen

After editing `football.*` keys in `Localizable.strings`:

```bash
./swiftgen/bin/swiftgen config run
```
