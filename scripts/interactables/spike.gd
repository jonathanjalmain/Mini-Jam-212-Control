extends Area2D

@export var delay_ticks := 0
@export var armed_by_default := false
@export var base_color := Color(1.0, 0.3, 0.35)

var _armed := false
var _arming := false
var _timer := 0

@onready var _vis: Polygon2D = get_node_or_null("Visual")

func _ready() -> void:
	add_to_group("resettable")
	reset_state()

func set_active(on: bool) -> void:
	if on:
		if not _armed and not _arming:
			if delay_ticks > 0:
				_arming = true
				_timer = delay_ticks
			else:
				_arm()
	else:
		_disarm()

func _physics_process(_delta: float) -> void:
	if _arming:
		_timer -= 1
		if _timer <= 0:
			_arming = false
			_arm()
	if _armed:
		for b in get_overlapping_bodies():
			if b.is_in_group("player") and b.has_method("die"):
				b.die()

func _arm() -> void:
	_armed = true
	_update_vis()

func _disarm() -> void:
	_armed = false
	_arming = false
	_update_vis()

func _update_vis() -> void:
	if _vis:
		_vis.color = base_color if _armed else Color(base_color.r * 0.35, base_color.g * 0.35, base_color.b * 0.35, 0.7)

func reset_state() -> void:
	_arming = false
	_armed = armed_by_default
	_update_vis()
