extends Node

signal ammo_changed(ammo: int)
signal cycle_changed(cycle: int, resets_left: int)
signal timer_changed(ratio: float)
signal clone_spawned(count: int)
signal clone_frozen
signal player_died
signal level_won
signal map_reset
signal log_line(text: String)
signal subtitle(text: String)
