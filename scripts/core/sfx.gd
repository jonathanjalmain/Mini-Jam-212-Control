extends Node

const DIR := "res://assets/soundEffect/"

var _players := {}

func _ready() -> void:
	_make("death", -5.0)
	_make("freezeClone", -6.0)
	_make("victory", -3.0)
	_make("resetCycle", -9.0)
	_make("resetPurge", -7.0)
	Events.player_died.connect(func() -> void: _play("death"))
	Events.clone_frozen.connect(func() -> void: _play("freezeClone"))
	Events.level_won.connect(func() -> void: _play("victory"))
	Events.map_reset.connect(func() -> void: _play("resetPurge"))
	Events.cycle_restarted.connect(func() -> void: _play("resetCycle"))

func _make(name: String, db: float) -> void:
	var p := AudioStreamPlayer.new()
	p.bus = "SFX"
	p.volume_db = db
	var path := DIR + name + ".mp3"
	if ResourceLoader.exists(path):
		p.stream = load(path)
	add_child(p)
	_players[name] = p

func _play(name: String) -> void:
	var p = _players.get(name)
	if p and p.stream:
		p.play()
