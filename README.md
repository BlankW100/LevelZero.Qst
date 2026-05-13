# LevelZero.Qst

An offline-first RPG habit tracker for Android built with Flutter. Complete real-life physical and mental tasks to earn XP, level up your Hunter, and grow your stats — inspired by the Solo Leveling / Cyberpunk aesthetic.

---

## Core Concept

You are a **Hunter**. Your real-life grind is the game. Every push-up, run, study session, or meditation session earns XP and raises your actual character stats. The harder you train, the stronger your Hunter becomes.

---

## Features

### Character System
- Choose a **Hunter Class** (Warrior, Assassin, Mage, Tank, Knight, Fighter, Ranger, Scholar)
- Level up by earning XP from completed quests
- Four core stats: **STR**, **AGI**, **INT**, **END**
- HP and MP scale dynamically with your stats and class

### Daily Quests
- Four quests generated daily — one per stat category
- Quest difficulty and amount are randomized within a range
- Completing a quest grants XP, Gold, and +1 to the relevant stat
- **Synergy bonus**: completing a quest that matches your class focus gives +50% XP, +50% Gold, and +2 stat points

### Monthly Training Planner
- Calendar on the Quest screen lets you assign a focus (STR / AGI / INT / END / REST) to each day
- Quest generation auto-targets the day's assigned focus

### Turn-Based Combat
- Enter dungeon gates from the Quest screen to fight monsters
- Retro terminal-style battle UI with ASCII art enemies
- Four actions: **SLASH** (STR), **CAST** (INT, costs MP), **BRACE** (END, reduces damage), **FLEE** (AGI-based escape chance)
- Victory rewards XP and Gold; defeat triggers an emergency teleport

### System Shop
- Daily rotating selection of 6 items (resets at midnight)
- Item prices are rarity-tiered — legendary items require days of saving
- Basic consumables (HP/MP flasks) available with a daily purchase limit
- Epic and Legendary items cannot appear twice in the same daily rotation

### Vault (Inventory)
- Grid-based inventory with 25 slots
- Filter items by category: Equipment, Material, Consumable, Other
- Tap any item to view stats, equip, use, or discard
- Equipping gear with a slot conflict triggers a side-by-side comparison UI before swapping

---

## Screens

| Screen | Description |
|---|---|
| Dashboard | Level, XP progress bar, stat cards, daily quest checklist |
| Quest Board | Active missions, monthly calendar planner, dungeon gate list |
| Stats | Full character stat breakdown |
| Shop | Daily rotating item shop with rarity-based pricing |
| Vault | Grid inventory with category filters and equip/use/discard actions |
| Profile | Coming soon |

---

## Item Rarities

| Rarity | Color | Price Range |
|---|---|---|
| Common | Grey | 1 – 20 G |
| Uncommon | Green | 21 – 60 G |
| Rare | Blue | 80 – 150 G |
| Epic | Purple | 200 – 350 G |
| Legendary | Gold | 450 – 700 G |

---

## Tech Stack

| | |
|---|---|
| Framework | Flutter (Dart) |
| Platform | Android |
| Storage | `shared_preferences` (fully offline, no cloud) |
| State | `setState` / standard Flutter |
| Theme | Strict dark mode — neon blue, purple, gold accents |

---

## Project Structure

```
lib/
├── data/         # Static data: monster database, quest pool, shop pool
├── models/       # Data classes: HunterProfile, Quest, Item, SystemTask
├── services/     # LocalStorage — all read/write to shared_preferences
├── theme/        # AppTheme — dark mode color scheme and text styles
├── ui/           # Full screens: dashboard, quest, combat, shop, vault, stats
└── widgets/      # Reusable components: QuestCard, StatBar
```

---

## Getting Started

```bash
# Install dependencies
flutter pub get

# Run on connected Android device or emulator
flutter run
```

Requires Flutter SDK `^3.11.4`.
