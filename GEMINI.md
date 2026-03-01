# Project: Seedling - Offline Pomodoro RPG
**Platform:** Flutter (Cross-platform)
**Architecture:** Offline-First, Feature-First
**Theme:** Fruit Growth & Alchemy

## 1. Overview
Seedling is a productivity application that gamifies Pomodoro sessions. Users grow fruit characters by completing focus intervals. The app is entirely self-contained, requiring no backend or paid external APIs.

## 2. Core Mechanics
### A. The Sunlight Cycle (Timer)
* **Interval:** 25-minute countdown (standard Pomodoro).
* **States:** * *Focusing:* Fruit asset pulses/breathes.
    * *Success:* Timer hits 0:00. Reward "Nectar" currency and XP.
    * *Interrupted:* User leaves app or cancels. Fruit enters "Drought" (visual greyscale/wilt).

### B. Fruit RPG Stats
Each fruit asset is a unique object with the following local data:
* **Sweetness (Level/XP):** Determines the growth stage (Seed -> Sprout -> Mature -> Ascended).
* **Zest (Multiplier):** Increases Nectar yield per session.
* **Durability (Protection):** A "buffer" that prevents XP loss if a session is failed.

### C. The Orchard (Local Storage)
* A grid-based gallery displaying all owned fruit assets.
* Users can switch their "Active Fruit" here.
* Data is persisted locally using Hive or Isar.

## 3. Asset Pipeline
The app will cycle through fruit assets based on growth stages:
1. **Stage 1 (Seed):** Generic placeholder.
2. **Stage 2 (Sprout):** Generic sprout asset.
3. **Stage 3 (Young):** Target Fruit Asset (Scaled down/Translucent).
4. **Stage 4 (Mature):** Target Fruit Asset (Full scale/Vibrant).
5. **Stage 5 (Ascended):** Target Fruit Asset + Custom Shader/Glow.

## 4. Technical Requirements (Solo Dev Focus)
* **Persistence (Local DB):** `hive` to store fruit stats, user progress, and session history locally.
* **State Management:** `bloc`, `signals`, or `riverpod` to manage the live timer logic, UI reactivity, and XP calculations during a session.
* **Notifications:** `flutter_local_notifications` for background alerts when a "Sunlight Cycle" completes.
* **Animations:** `AnimationController` for the fruit "breathing" effects and growth transitions.
* **Concurrency:** Use `Isolates` for the countdown timer logic to ensure millisecond accuracy even if the UI thread is under heavy load.

## 5. Data Model Schema (JSON/Object)
{
"id": "string",
"fruit_type": "apple|orange|etc",
"xp": "int",
"level": "int",
"zest_rating": "double",
"durability_points": "int",
"last_harvest": "timestamp"
}