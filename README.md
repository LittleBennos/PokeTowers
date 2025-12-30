# PokeTowers

Pokemon-themed tower defense game built with Godot 4.5.

## Features

- **4 Towers**: Pikachu, Squirtle, Charmander, Bulbasaur with type effectiveness
- **5 Enemy Types**: Caterpie, Weedle, Pidgey, Metapod, Kakuna
- **10 Waves** of increasing difficulty
- **Type System**: Fire > Grass > Water > Fire, Electric > Water, etc.
- **Map Editor**: Built-in path editor tool

## Controls

- **Click tower** in left panel to select
- **Click map** to place tower
- **Right-click** to cancel placement
- **Start Wave** button to begin

## Project Structure

```
scenes/
  main.tscn          # Main game scene
  ui/
    main_menu.tscn   # Title screen
    hud.tscn         # In-game UI
    map_select.tscn  # Map editor selection
  tools/
    path_editor.tscn # Path drawing tool
  towers/            # Tower scenes
  enemies/           # Enemy scenes

scripts/
  autoload/
    game_manager.gd  # Global state
  towers/            # Tower logic
  enemies/           # Enemy logic
  ui/                # UI scripts

assets/
  sprites/           # Pokemon sprites & backgrounds
  audio/             # Sound effects (empty)
```

## Requirements

- Godot 4.5+

## License

For educational purposes only. Pokemon is a trademark of Nintendo/Game Freak.
