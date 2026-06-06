extends Area2D

@export var targets: Array[NodePath] = []
@export var base_color := Color(1.0, 0.72, 0.2)

var pressed := false

@onready var _vis: Polygon2D = get_node_or_null("Visual")
var _sfx: AudioStreamPlayer

func _ready() -> void:
	add_to_group("resettable")
	_sfx = AudioStreamPlayer.new()
	_sfx.bus = "SFX"
	_sfx.volume_db = -10.0
	var path := "res://assets/soundEffect/pressurePlate.mp3"
	if ResourceLoader.exists(path):
		_sfx.stream = load(path)
	add_child(_sfx)
	_apply()

func _physics_process(_delta: float) -> void:
	var now := not get_overlapping_bodies().is_empty()
	if now != pressed:
		pressed = now
		if now and _sfx.stream:
			_sfx.play()
		_apply()

func _apply() -> void:
	if _vis:
		_vis.color = base_color if pressed else base_color * 0.4
	for np in targets:
		var t := get_node_or_null(np)
		if t and t.has_method("set_active"):
			t.set_active(pressed)

func reset_state() -> void:
	pressed = false
	_apply()
