extends StaticBody2D

@export var inverted := false
@export var base_color := Color(1.0, 0.72, 0.2)

var _open := false
var _audible := false

var _shape: CollisionShape2D
var _vis: Polygon2D
var _sfx: AudioStreamPlayer

func _ready() -> void:
	add_to_group("resettable")
	_sfx = AudioStreamPlayer.new()
	_sfx.bus = "SFX"
	_sfx.volume_db = -9.0
	var path := "res://assets/soundEffect/door.mp3"
	if ResourceLoader.exists(path):
		_sfx.stream = load(path)
	add_child(_sfx)
	reset_state()
	_audible = true

func set_active(on: bool) -> void:
	var was := _open
	_open = on if not inverted else not on
	_apply()
	if _audible and _open != was and _sfx and _sfx.stream:
		_sfx.play()

func _apply() -> void:
	if _shape == null:
		_shape = get_node_or_null("Shape")
	if _vis == null:
		_vis = get_node_or_null("Visual")
	if _shape:
		_shape.set_deferred("disabled", _open)
	if _vis:
		_vis.color = Color(base_color.r, base_color.g, base_color.b, 0.1 if _open else 0.95)

func reset_state() -> void:
	var prev := _audible
	_audible = false
	set_active(false)
	_audible = prev
