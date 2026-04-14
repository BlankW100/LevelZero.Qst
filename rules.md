# App Architecture Rules: "System Leveling"

## 1. Project Overview
* **Type:** Offline-first RPG habit tracker and task manager.
* **Core Loop:** Users complete daily physical/mental tasks to earn XP and level up real-life stats (STR, AGI, INT, END).

## 2. Tech Stack & State
* **Framework:** Flutter (Dart).
* **Storage:** `shared_preferences` exclusively. No Firebase, no Supabase, no external databases.
* **State Management:** Keep it simple. Use standard `setState` or basic `ValueNotifier` unless otherwise specified.

## 3. Directory Structure Enforcement
* `/models`: Only simple classes and data objects.
* `/services`: Business logic, storage handling, and task generation.
* `/ui`: Full-page screens.
* `/widgets`: Reusable custom UI components.
* `/theme`: All colors, text styles, and theme data.

## 4. Design System
* **Theme:** Strict Dark Mode. 
* **Vibe:** Solo Leveling / Cyberpunk / RPG aesthetics. Use high-contrast accents (neon blue, purple, glowing green).

## 5. AI Output Rules (CRITICAL)
* Write clean, modular, and well-commented Dart code.
* Output strictly formatted code blocks to ensure the VS Code "Apply Code" diff feature works perfectly.
* Do not delete existing code unless explicitly asked to refactor it.
* Avoid lengthy markdown explanations. Just write the code.