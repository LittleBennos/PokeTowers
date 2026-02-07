# Changelog

## [0.3.0] - 2026-02-08 — Bug Fix & Polish Pass

### Fixed
- **Critical: Dynamic enemies invisible to towers** — `base_enemy.tscn` was missing its `Area2D` node, so dynamically spawned enemies (from the wave generation system) had no collision body on layer 2. Towers could never detect or attack them. Only legacy pre-built enemy scenes (caterpie.tscn, etc.) worked.
- **Save migration never re-saved** — After migrating a v1 save to v2, the re-save check compared `version == 1` but the variable had already been set to 2. Migrated saves were loaded correctly but never persisted in the new format.
- **Legacy HUD crash** — `hud.gd` referenced non-existent `GameManager.currency_changed` signal and `GameManager.currency` property (renamed to `zenny_changed`/`zenny` in the individual Pokémon update). Fixed to use correct signal.
- **Party select didn't remember previous party** — Opening the party select screen always started with an empty party. Now pre-loads the existing party so players don't have to re-select every time.
- **Division by zero in catch rate** — `calculate_catch_rate` could divide by zero if an enemy had `max_hp <= 0`.

### Improved
- **Evolution now updates tower stats** — Previously, when a tower Pokémon evolved mid-battle, only the species ID changed (with a TODO comment). Now evolution properly updates damage, range, attack speed, type, and recalculates the range circle.
- **Starter Pokémon `base_stat_range`** — Added explicit range stat values to Bulbasaur (50), Charmander (40), and Squirtle (55) resources instead of relying on the script default.

## [0.2.0] - 2026-02-07 — Individual Values System

### Added
- **IV (Individual Values) system** — Each caught Pokémon now has 5 random IVs (0–31): Physical Attack, Special Attack, Defense, Speed, and Range
- **IV-based stat scaling** — Tower damage, defense, speed, and range scale with IVs (up to 1.3× at 31)
- **Pokémon stat formula** — Damage calculation uses mainline-style `((base + IV) × 2) × level / 100 + 5`
- **Move system** — Pokémon learn moves from learnsets on level-up; towers select the best move per-enemy
- **Star rating** — 0–5 star IV quality display; "PERFECT" badge for all-31 IVs
- **Tower panel** — Click a placed tower to see its level, XP, IVs, and moves; learn or skip new moves
- **Perfect IV indicators** — Gold star badges and particle effects on towers with perfect IVs
- **UUID-based Pokémon** — Each caught Pokémon is a unique individual with a UUID (save format v2)
- **Save migration** — v1 saves (species-keyed) automatically migrate to v2 (UUID-keyed)

## [0.1.0] - 2026-02-07 — Dynamic Waves & Maps

### Added
- Dynamic wave generation system with per-map enemy pools
- Campaign/region selection with 8 regions (Kanto through Galar)
- Map progression system with lock/unlock
- Map editor tool for path and zone placement
- Background scaling and offset for maps
- Zenny meta-currency earned on run completion
- Party size upgrade system
- Auto-start waves checkbox
- Ball selection for catching (Poké Ball, Great Ball, Ultra Ball)
- 250+ Pokémon species resources (Gens 1–3)
- Animated spritesheets for towers and enemies

## [0.0.1] - 2026-02-07 — Initial Release

### Added
- Core tower defense gameplay loop
- Tower placement on grid zones
- Basic wave system with 10 waves
- Type effectiveness chart (9 types)
- Pokémon catching mechanic (auto-catch at <25% HP)
- Save/load system with 3 slots
- Starter selection (Bulbasaur, Charmander, Squirtle)
