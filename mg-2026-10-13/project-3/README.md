# Project 3 — Dodge the Creeps!

Adapted from Godot's [Your first 2D game](https://docs.godotengine.org/en/stable/getting_started/first_2d_game/index.html) tutorial.

## Play
Open this directory in Godot 4 and run **Game.tscn** (F5).

- Move: WASD or arrow keys
- Start / replay: click **Start** or press **Enter**
- Avoid randomly spawned enemies and survive to build your score.
- You have 3 HP and a short damage-invulnerability interval.

## Scenes
- `Game.tscn` + `game.gd`: main loop, MobTimer, ScoreTimer, StartTimer, border Path2D and audio
- `player.tscn` + `player.gd`: movement, animation, contact damage, health
- `enemy.tscn` + `enemy.gd`: randomly selected fly/swim/walk animation; frees itself on leaving view
- `hud.tscn` + `hud.gd`: score, HP, game-over/start UI

## Tutorial differences
Retains the earlier project's **3 HP and invincibility** rather than ending on the first hit. Enemy recycling was replaced with tutorial-style periodic spawning and deletion; this prevents perpetual enemies from carrying across rounds. Enemy sprites and sound files come from the existing tutorial asset folder.
