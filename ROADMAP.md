# PokeTowers Enhancement Roadmap

*Generated: 2026-02-08*

## Current State Summary

PokeTowers is a **Godot 4.5** Pokemon-themed tower defense game with substantial foundations already in place:

### ✅ Implemented
- **Core TD loop**: Tower placement on zones, Path2D enemies, wave spawning, lives/currency
- **Type system**: 9 types (Normal, Fire, Water, Grass, Electric, Ground, Rock, Flying, Bug) with effectiveness chart
- **Type-based attacks**: Electric=chain lightning, Fire=AOE projectile, Water=slow projectile, Grass=poison DOT, Rock=splash, Ground=cone, Bug=multi-hit
- **Pokemon data system**: ~200+ species defined as resources with stats, icons, learnsets
- **Move system**: 15 moves with physical/special categories, Pokemon damage formula with STAB
- **Catching mechanic**: Auto-catch at <25% HP, ball types (Poke/Great/Ultra), catch rate formula
- **Evolution**: Level-based evolution tracking (visual swap TODO)
- **Save system**: 3 save slots via SaveManager autoload
- **Campaign structure**: 8 regions (Kanto→Galar), each with ~6 maps, progression unlocking
- **Party system**: Select Pokemon before each map, party size upgrades with Zenny
- **UI flow**: Main Menu → Save Select → Starter Select → Campaign Select → Map Select → Party Select → Game
- **Map editor tool**: Path + zone editing with export
- **Projectile system**: Homing projectiles with fire (AOE) and water (slow) variants
- **Visual effects**: Damage numbers, lightning lines, particle effects per type, flash on super effective
- **XP/Leveling**: Towers gain XP from kills, level up with stat scaling
- **Dynamic wave generation**: Scales with difficulty, wave number; boss waves every 5th; final wave epic

### ❌ Missing / Incomplete
- No sound/music at all
- No touch/mobile input support
- No responsive scaling for mobile aspect ratios
- Evolution doesn't visually swap the tower scene/sprite (TODO in code)
- No tower upgrade/sell UI for placed towers
- No speed control (fast-forward/pause)
- No tutorial or onboarding
- No particle effects for projectile impacts beyond fire/water
- No idle animations on most enemies (only ~10 have spritesheets, rest use static icons)
- HUD still has legacy tower_data dict (outdated, party system is the real flow)
- No Pokedex viewer screen
- No settings screen (volume, etc.)
- No victory rewards screen (Zenny payout, catches summary)

---

## Priority 1: Quick Wins 🏃

*Low effort, high impact. Can be done in 1-2 sessions each.*

### 1.1 Game Speed Controls
Add 1x/2x/3x speed buttons to HUD. Just modify `Engine.time_scale`.

### 1.2 Tower Sell Button
When a placed tower is selected (`GameManager.tower_selected` signal already exists), show a sell button that refunds 50-75% cost and frees the zone.

### 1.3 Evolution Visual Swap
`check_evolution()` in base_tower.gd has a TODO. Load new species data, swap sprite/animated_sprite, update stats. The signal `pokemon_evolved` already fires.

### 1.4 Wave Complete Auto-Enable
`wave_completed` signal exists but HUD doesn't reliably re-enable Start Wave button. Wire it up cleanly.

### 1.5 Clean Up Legacy HUD
`hud.gd` still has a hardcoded `tower_data` dict for pikachu/squirtle/etc. The real flow uses party_select → placed towers. Remove dead code or gate it behind a "classic mode" flag.

---

## Priority 2: Mobile-Ready UI 📱

### 2.1 Touch Input Support
- Tower placement: long-press to pick from party, drag to zone, release to place
- Tower selection: tap on placed tower to show info/sell popup
- Replace right-click cancel with a cancel button or swipe gesture
- Add touch-friendly button sizes (minimum 48dp tap targets)

### 2.2 Responsive Scaling
- Current: fixed 1280×720, `canvas_items` stretch
- Add: UI anchoring for different aspect ratios (16:9, 18:9, 4:3)
- Side panels should collapse/overlay on narrow screens
- Consider portrait mode layout option (path area top, controls bottom)

### 2.3 Mobile HUD Redesign
- Bottom-anchored party bar with larger icons
- Floating action buttons (Start Wave, Speed, Pause)
- Swipe-up tower info panel instead of side panel
- Pinch-to-zoom on map area

---

## Priority 3: Wave & Balance Improvements ⚖️

### 3.1 Difficulty Curve Tuning
- Early waves feel balanced but mid-game can spike hard with high-level enemies
- Add `enemy_hp_scale` and `enemy_speed_scale` per-map to fine-tune
- Boss waves should telegraph (visual warning before wave 5, 10, etc.)

### 3.2 Wave Preview
Show upcoming wave composition before starting (species icons + count). Players can strategize tower placement.

### 3.3 Income System
Between-wave currency bonus based on lives remaining (interest mechanic). Rewards conservative play.

### 3.4 Type Diversity in Waves
Current generator picks 1-3 random species. Weight selection to ensure type variety so players need diverse teams.

### 3.5 Endless Mode
After clearing all waves, offer endless mode with infinitely scaling difficulty. Leaderboard potential.

---

## Priority 4: New Pokemon/Tower Types 🆕

### 4.1 Missing Types: Ice, Poison, Ghost, Dragon, Psychic, Fighting, Dark, Steel, Fairy
Currently only 9 of 18 types. Priority additions:
- **Ice**: Freeze effect (full stop for 1s, then slow). Strong vs Dragon/Grass/Flying
- **Psychic**: Confuse effect (enemy reverses direction briefly). Strong vs Fighting/Poison
- **Dragon**: High damage, long range, slow attack speed. Strong vs Dragon
- **Fighting**: Melee-range high DPS. Strong vs Normal/Rock/Steel/Ice
- **Ghost**: Attacks ignore armor/defense. Strong vs Ghost/Psychic
- **Dark**: Reduces enemy reward on kill (thief) but high base damage
- **Steel**: Defensive aura tower (reduces damage to nearby towers). Strong vs Ice/Rock/Fairy
- **Fairy**: Heals nearby towers / buff aura. Strong vs Dragon/Dark/Fighting

### 4.2 Tower Specializations
Let evolved Pokemon choose between 2 specialization paths:
- Charizard: AOE focus vs single-target burn
- Blastoise: Slow focus vs knockback cannon
- Venusaur: Poison cloud vs heal aura for adjacent towers

### 4.3 Legendary Towers
Legendaries from boss_pool could be catchable as ultra-rare tower options with unique abilities.

---

## Priority 5: Visual Polish ✨

### 5.1 Spritesheet Coverage
Only ~10 Pokemon have idle spritesheets. For the 200+ species using static icons:
- Source or generate idle animations (2-4 frame bounce/sway)
- Attack animations for tower Pokemon
- Hit reaction frames for enemies

### 5.2 Projectile Variety
- Electric: bolt projectile (currently instant chain, fine)
- Grass: leaf/vine projectile instead of instant
- Rock: boulder arc projectile
- Ground: ground crack line effect
- Bug: swarm particle projectile

### 5.3 Map Visual Themes
Maps currently share generic backgrounds. Add:
- Themed tilesets per region
- Ambient particles (leaves in forests, snow in ice caves, sand in desert)
- Day/night cycle per map

### 5.4 UI Polish
- Animated transitions between menu screens
- Pokemon card flip animation on catch
- Tower placement ghost preview (semi-transparent sprite at cursor)
- Range indicator during placement (already exists, ensure it shows)
- Health bar color gradient (green → yellow → red)

### 5.5 Screen Shake & Juice
- Camera shake on boss spawn
- Tower recoil on attack
- Enemy death poof animation
- Wave complete celebration particles

---

## Priority 6: Sound & Music 🎵

### 6.1 Sound Effects (Priority)
- Tower attack sounds per type (zap, splash, flame burst, etc.)
- Enemy hit / death sounds
- Pokemon catch jingle (success) and fail sound
- UI clicks, button hovers
- Wave start horn / wave complete chime
- Level up / evolution fanfare
- Game over / victory stingers

### 6.2 Background Music
- Main menu theme
- Battle music per region (or generic battle + boss variant)
- Victory/defeat screens
- Map select ambient music

### 6.3 Audio System
- Create AudioManager autoload
- Music crossfade between scenes
- SFX pooling (avoid spawning too many AudioStreamPlayer nodes)
- Volume settings (master, music, SFX) with persistence in save

---

## Priority 7: Progression & Meta 🏆

### 7.1 Victory Rewards Screen
After winning a map: show Zenny earned, Pokemon caught, XP gained. Currently just "YOU WIN!" text.

### 7.2 Pokedex Screen
Browse all seen/caught Pokemon. Show stats, type, caught count. Accessible from main menu.

### 7.3 Pokemon Storage/PC
Manage caught Pokemon outside of party. Transfer between party and storage.

### 7.4 Achievement System
- "Catch 'em all" per region
- "Win without losing a life"
- "Evolve X Pokemon"
- Reward Zenny or unlock cosmetics

### 7.5 Tutorial / First-Time Experience
Guided first map: place tutorial, type effectiveness explanation, catching explanation.

---

## Implementation Order Suggestion

| Phase | Items | Effort |
|-------|-------|--------|
| **Sprint 1** | Quick Wins (1.1-1.5) | 1-2 days |
| **Sprint 2** | Sound Effects (6.1) + Victory Screen (7.1) | 2-3 days |
| **Sprint 3** | Mobile Touch (2.1-2.2) | 3-4 days |
| **Sprint 4** | Wave Preview (3.2) + Speed Control polish + Balance (3.1) | 2 days |
| **Sprint 5** | New Types (4.1 - Ice, Psychic, Fighting) | 3 days |
| **Sprint 6** | Visual Polish (5.4, 5.5) + BGM (6.2) | 3 days |
| **Sprint 7** | Pokedex (7.2) + Tutorial (7.5) | 3 days |
| **Sprint 8** | Remaining types + Endless mode + Achievements | Ongoing |
