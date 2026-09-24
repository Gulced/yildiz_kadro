# Yıldız Kadro

**Yıldız Kadro** is a bilingual Flutter simulation game in which the player produces a multi-day talent competition, evaluates contestants, manages teams and backstage decisions, and builds a final debut lineup.

The project combines a large stateful campaign, deterministic simulation engines, branching narrative events, responsive interfaces, and Turkish/English localization in a feature-oriented mobile codebase.

## Overview

The player begins with a cast of 15 contestants and guides the season through first impressions, evaluations, jury decisions, last-chance performances, group missions, live stages, and a grand final. Decisions made during the season affect contestant scores, relationships, team dynamics, risk states, eliminations, and the composition of the final group.

Yıldız Kadro is implemented as an offline, single-player simulation. Its results come from domain-specific Dart logic—not from machine-learning models or remote AI services. A season seed keeps generated outcomes reproducible while still allowing different seasons to produce different events and rankings.

## Key Features

- Multi-stage competition spanning casting, evaluation, elimination, group missions, live performance, and a grand final
- Fifteen contestants with stable identities, performance attributes, work styles, social state, and relationship data
- Seeded simulation engines for repeatable team drafts, rehearsals, performance results, jury decisions, duels, and final rankings
- Manual team building with captain selection, role assignment, compatibility analysis, and player intervention
- Branching backstage story events whose choices can update contestant state, relationships, and later event availability
- Producer and jury save mechanics followed by coached last-chance performances
- Final-lineup selection, position assignment, leader selection, member colors, group naming, and season archive
- Immediate Turkish/English language switching with persisted locale preference
- Responsive phone/tablet layouts and large-text regression coverage
- Automated unit, widget, localization, deterministic-simulation, and end-to-end season-flow tests

## Season Flow

```text
Casting & Player Radar
        ↓
First Impression
        ↓
Evaluation → Producer/Jury Decision → Last Chance → Elimination
        ↓
Day 2: Team Draft → Rehearsal → Group Performance → Jury → Duel
        ↓
Day 3: Identity Mission → Icon Performance → Final Cut
        ↓
Day 4: Position Battle
        ↓
Day 5: Live Show
        ↓
Day 6: Grand Final → Player Lineup → Group Customization
        ↓
Season Recap & Group Archive
```

Backstage story events can appear between stages. Their effects are applied to the shared season state and can influence later simulation inputs.

## Tech Stack

### Mobile

- Flutter
- Dart
- Material UI

### State and Persistence

- `ChangeNotifier` and inherited scopes for shared game and locale state
- Widget-local state for screen-specific, phased interactions
- `SharedPreferences` for locale persistence
- Seeded deterministic simulation for reproducible seasons

### Localization

- Flutter localization generation
- ARB resources for Turkish and English
- Runtime locale switching through a dedicated `LocaleController`

### Testing

- Flutter Test
- Unit tests for simulation and state-transition logic
- Widget tests for navigation and responsive behavior
- Localization audit and runtime regression tests
- Full-flow release-candidate QA tests in both supported languages

## Architecture

The application uses a **feature-oriented architecture**. Presentation widgets, domain models, and simulation/data logic are grouped by gameplay area. Shared application state is held by `GameState`, exposed through `GameScope`, and observed by the UI through Flutter listenable primitives.

```text
Flutter UI / Feature Screens
             ↓
       GameScope
             ↓
         GameState
             ↓
Domain Models & Simulation Engines
             ↓
Seed Data / Story Catalog / Local Preferences
```

This is not a networked or database-backed architecture. Gameplay state lives in memory for the active season; only the selected locale is persisted with `SharedPreferences`.

## Project Structure

```text
lib/
├── app/
│   ├── app.dart                 # Application composition
│   ├── localization/            # Locale controller and scope
│   ├── navigation/              # Global navigation observation
│   └── theme/                   # Application theme
├── core/
│   └── responsive/              # Responsive layout utilities
├── features/
│   ├── contestants/             # Contestant domain, seed data, profiles, UI
│   ├── evaluation/              # First evaluation and reveal flow
│   ├── first_impression/        # Opening competition stage
│   ├── game/                    # Shared season state and scope
│   ├── group_task/              # Day 2–6 simulation engines and screens
│   ├── jury/                    # Jury and producer decision flow
│   ├── last_chance/             # Coaching, performance, and elimination
│   ├── postgame/                # Final group creation and season archive
│   ├── producer/                # Backstage events and producer dashboard
│   └── roster/                  # Active/eliminated roster presentation
├── l10n/                        # Generated localization bindings and ARB files
├── shared/widgets/              # Reusable gameplay and editorial components
└── main.dart                    # Application entry point

assets/
└── contestants/                 # Contestant portrait assets

test/
├── widget_test.dart
├── localization_audit_test.dart
├── runtime_localization_regression_test.dart
└── release_candidate_qa_test.dart
```

## Core Systems

### Season State

`GameState` is the source of truth for the current campaign. It records evaluation results, saves, eliminations, team assignments, rehearsal outcomes, stage snapshots, social state, story history, finalists, final roles, and archived groups. Public collections are exposed as immutable views to prevent accidental mutation outside the state owner.

### Simulation Engines

Each major stage has dedicated calculation code rather than embedding scoring rules in UI widgets. The engines combine contestant profiles, player choices, team composition, previous results, and a season seed to produce typed result snapshots.

Examples include:

- Team compatibility and seeded drafting
- Rehearsal role allocation and crisis resolution
- Group performance and jury-risk calculation
- Duel, identity, icon, final-cut, position, live-show, and grand-final scoring
- Final-lineup balance and automatic group-tag generation

### Story Event System

The producer layer schedules a controlled number of backstage events across a season. Event selection avoids recent repetition, supports prerequisite decision flags, and resolves choice effects against contestant personality and relationship data. Resolved events are stored once so rebuilding a screen does not apply an outcome repeatedly.

### Localization

Turkish and English strings are supplied through Flutter's generated localization layer. Contestant presentation data and story-event content have locale-aware accessors, while simulation inputs and rankings remain language-independent. The selected locale is restored when the application starts.

### Final Group and Archive

After the grand final, the player can confirm a lineup, assign member positions, select a leader, choose member colors, name the group, and review generated group tags. Completed groups can be stored in the in-memory season archive for postgame presentation.

## Getting Started

### Prerequisites

- Flutter SDK compatible with Dart `^3.13.1`
- A configured Flutter target such as an iOS Simulator or Android Emulator

### Install

```bash
git clone https://github.com/Gulced/yildiz_kadro.git
cd yildiz_kadro
flutter pub get
```

### Run

```bash
flutter run
```

No API key, backend service, or database configuration is required.

## Testing

Run the complete suite:

```bash
flutter test
```

Run focused quality checks:

```bash
flutter test test/localization_audit_test.dart
flutter test test/runtime_localization_regression_test.dart
flutter test test/release_candidate_qa_test.dart
```

The tests cover deterministic rankings, team validity, state locking, story-event behavior, localization parity, large-text layouts, navigation recovery, and multi-day flows in Turkish and English.

## Technical Highlights

- A single typed season state coordinates many dependent stages without coupling scoring logic to presentation widgets.
- Seeded engines make complex outcomes reproducible and directly testable.
- Stage results are captured as domain snapshots and reused by later days instead of being recalculated from UI state.
- Story decisions affect persistent social and relationship state and can unlock downstream event branches.
- Localization tests verify that changing language never changes simulation data, seeds, or rankings.
- Release-candidate widget tests exercise long gameplay paths across both locales and multiple viewport constraints.

## Current Scope

- Gameplay is single-player and offline.
- Active season data is held in memory; reopening the application does not restore an unfinished season.
- The project does not use a backend, cloud database, analytics service, or machine-learning model.
- Localization preference is the only value currently persisted between launches.

## Possible Improvements

- Persist and restore complete season state locally.
- Add explicit save slots and archived-season serialization.
- Add integration or golden tests for the most visually complex stages.
- Improve accessibility semantics alongside the existing large-text coverage.
- Add CI workflows for formatting, static analysis, and automated tests.
