# PokeTowers

Pokemon-themed tower defense game built with Godot 4.

## Play Locally

1. Install [Godot 4.3+](https://godotengine.org/download)
2. Clone this repo: `git clone https://github.com/LittleBennos/PokeTowers.git`
3. Open Godot → Import → Select `project.godot`
4. Press F5 or click Play

## Features

- **Type-based attacks**: Electric=chain lightning, Fire=AOE, Water=slow, Grass=poison
- **Save system**: 3 save slots with starter selection
- **Party system**: Choose pokemon before each map
- **Catching**: Weaken enemies to catch them
- **8 Regions**: Kanto, Johto, Hoenn, Sinnoh, Unova, Kalos, Alola, Galar

## Controls

- Click pokemon in party panel to select
- Click placement zone to deploy (costs currency)
- Right-click to cancel
- Start Wave button to begin

## Project Structure

```
resources/
  pokemon/       # Species data (stats, types, costs)
  maps/          # Map definitions
  campaigns/     # Region data

scenes/
  towers/        # Generic tower scene
  enemies/       # Enemy scenes
  ui/            # Menu screens

scripts/
  autoload/      # GameManager, SaveManager
  resources/     # Resource classes
  towers/        # Tower logic (type-based attacks)
  enemies/       # Enemy logic
```

## Roadmap

See [ROADMAP.md](ROADMAP.md) for the full development roadmap with prioritised enhancements across 7 tiers and an 8-sprint implementation plan.

## Requirements

- Godot 4.3+

## License

For educational purposes only. Pokemon is a trademark of Nintendo/Game Freak.
add storage system
