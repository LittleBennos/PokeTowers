# PokeTowers — Playable Demo

## How to Run

1. Open the project in **Godot 4.5+**
2. Press **F5** (or Play) — the demo scene is set as the main scene

## What You Get

- **3 starter Pokémon** at Level 5: Bulbasaur (Grass), Charmander (Fire), Squirtle (Water)
- **500 Zenny** starting currency for catching enemies
- **Route 1 map** with 8 waves of wild Pokémon (Rattata, Pidgey, Caterpie, Weedle) and boss waves (Raticate, Pidgeotto)

## Core Gameplay Loop

1. **Place towers** — Click a Pokémon in the left party panel, then click a green placement zone on the map
2. **Start waves** — Click "START WAVE" in the right panel to send enemies down the path
3. **Type effectiveness** — Charmander (Fire) is super effective vs Bug types (Caterpie, Weedle); Squirtle (Water) has neutral coverage; Bulbasaur (Grass) covers well but is weak to Bug and Flying
4. **Auto-catch** — When enemies drop below 25% HP, the game automatically attempts to catch them using your selected ball type (costs Zenny)
5. **Win/Lose** — Survive all 8 waves to win. Enemies that reach the end of the path cost lives (20 total)

## Controls

- **Left click** on party card → select Pokémon for placement
- **Left click** on green zone → place selected Pokémon
- **Right click** → cancel placement
- **Left click** on placed tower → view tower info

## Switching Back to Full Game

To restore the main menu as the launch scene, change `run/main_scene` in `project.godot`:

```
run/main_scene="res://scenes/ui/main_menu.tscn"
```
