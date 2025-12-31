# PokeTowers

Pokemon-themed tower defense game in Godot 4.

## Project Structure

```
scenes/
  main.tscn              - game level (loads MapData)
  towers/*.tscn          - tower scenes (pikachu, squirtle, etc)
  enemies/*.tscn         - enemy scenes (caterpie, pidgey, etc)
  ui/*.tscn              - menus, HUD
  tools/path_editor.tscn - map editing tool

scripts/
  main.gd                - level loading
  tower_placement.gd     - zone spawning, placement logic
  wave_manager.gd        - enemy spawning, wave definitions
  towers/base_tower.gd   - tower base class
  enemies/base_enemy.gd  - enemy base class
  autoload/game_manager.gd - global state singleton
  resources/map_data.gd  - MapData resource class

resources/
  maps/*.tres            - map data files
```

## Core Systems

### GameManager (Autoload)
Global singleton for game state:
- `currency`, `lives`, `current_wave`
- `is_placing_tower`, `selected_tower_type`
- Type effectiveness chart (PokemonType enum)
- Signals: `currency_changed`, `lives_changed`, `wave_changed`, `game_over`

### Map System
Maps stored as MapData resources (.tres):
```gdscript
class_name MapData extends Resource
@export var map_name: String
@export var background: Texture2D
@export var path_points: PackedVector2Array
@export var zones: PackedVector2Array
@export var zone_size: int = 40
```

main.gd loads map via `@export var map_data: MapData`

### Tower System
BaseTower (scripts/towers/base_tower.gd):
- `damage`, `attack_range`, `attack_speed`, `cost`
- `pokemon_type` - for type effectiveness
- Targets enemy closest to path end (highest progress_ratio)
- Override `attack()` for special behaviors

Towers: pikachu (electric), squirtle (water), charmander (fire), bulbasaur (grass)

### Enemy System
BaseEnemy (scripts/enemies/base_enemy.gd):
- Extends PathFollow2D - moves along Path2D curve
- `max_hp`, `speed`, `reward`, `pokemon_type`
- Status effects: `apply_slow()`, `apply_poison()`
- Emits `died` signal when killed

Enemies: caterpie, weedle, pidgey, metapod, kakuna, rattata, geodude

### Wave System
WaveManager spawns enemies:
- `wave_definitions` array defines waves
- Format: `[{"type": "caterpie", "count": 6}, ...]`
- Spawns shuffled, `spawn_interval` seconds apart

### Type Effectiveness
```
FIRE > GRASS, BUG
WATER > FIRE, GROUND
GRASS > WATER, GROUND
ELECTRIC > WATER (immune to GROUND)
```
2.0x = super effective, 0.5x = not effective, 0.0x = immune

## Creating New Maps

1. Run path_editor.tscn
2. PATH mode: click to add enemy path waypoints
3. ZONES mode: click to add tower zones (scroll = resize)
4. Copy button exports data
5. Create .tres in resources/maps/:
```
[gd_resource type="Resource" script_class="MapData" load_steps=3 format=3]
[ext_resource type="Script" path="res://scripts/resources/map_data.gd" id="1"]
[ext_resource type="Texture2D" path="res://assets/sprites/bg.jpg" id="2"]
[resource]
script = ExtResource("1")
map_name = "Map Name"
background = ExtResource("2")
path_points = PackedVector2Array(x1, y1, x2, y2, ...)
zones = PackedVector2Array(x1, y1, x2, y2, ...)
zone_size = 40
```

## Adding Enemies

1. Create scene extending base_enemy.tscn
2. Attach script extending BaseEnemy
3. Set exports: max_hp, speed, reward, pokemon_type
4. Add to wave_manager.gd `enemy_scenes`
5. Add to wave_definitions

## Projectile System

Projectiles in `scripts/projectiles/`:
- `base_projectile.gd` - homes toward target, collision detection
- `water_projectile.gd` - applies slow on hit
- `fire_projectile.gd` - AoE explosion on impact

## Visual Effects

- `DamageNumber` - floating damage popups (gold=super effective, grey=weak)
- Pikachu: chain lightning (Line2D)
- Charmander: explosion circle + fire particles
- Squirtle: water splash particles
- Bulbasaur: poison tint + cloud particles

## IMPORTANT: SubViewport Coordinate Space

The game uses a SubViewport for the play area (game_root.tscn embeds main.tscn in SubViewport). This means:

**NEVER use `get_tree().root.add_child()` for visual effects!**

The root Window and SubViewport have different coordinate spaces. Effects added to root will appear in wrong positions.

**Correct patterns:**
```gdscript
# From tower/enemy/projectile - use viewport
get_viewport().add_child(effect)

# From tower - add projectile as sibling
get_parent().add_child(projectile)
projectile.global_position = global_position  # Set AFTER adding

# For damage numbers
DamageNumber.spawn(get_viewport(), pos, amount, multiplier)
```

## Adding Towers

1. Create TowerData resource in `resources/towers/`:
```
[gd_resource type="Resource" script_class="TowerData" load_steps=4 format=3]
[ext_resource type="Script" path="res://scripts/resources/tower_data.gd" id="1"]
[ext_resource type="Texture2D" path="res://assets/sprites/pokemon.png" id="2"]
[ext_resource type="PackedScene" path="res://scenes/towers/pokemon.tscn" id="3"]
[resource]
script = ExtResource("1")
id = "pokemon"
display_name = "Pokemon"
pokemon_type = 0
cost = 100
damage = 10.0
attack_range = 150.0
attack_speed = 1.0
icon = ExtResource("2")
scene = ExtResource("3")
```
2. Create tower scene extending base_tower.tscn
3. Override `attack()` for special behaviors
4. Add to `tower_placement.gd` tower_data dictionary
5. Add to `game_root.gd` load_tower_resources()

## IMPORTANT: Tweens on Freed Nodes

`create_tween()` binds the tween to `self`. If the node is freed (e.g., projectile after hit), the tween dies and effects won't complete.

**For effects that outlive the current node:**
```gdscript
# BAD - tween dies when projectile is freed
var tween = create_tween()

# GOOD - tween survives node being freed
var tween = get_tree().create_tween()
```

## Conventions

- Zone size: 40x40 (configurable per map)
- Game resolution: 880x720
- Towers target by progress_ratio (closest to end)
- All game state through GameManager signals
- **Use get_viewport() not get_tree().root for effects**
- **Use get_tree().create_tween() for effects on freed nodes**
