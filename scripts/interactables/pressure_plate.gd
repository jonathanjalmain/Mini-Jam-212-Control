extends Area2D

@export var targets: Array[NodePath] = []
@export var base_color := Color(1.0, 0.72, 0.2)

var pressed := false

@onready var _vis: Polygon2D = get_node_or_null("Visual")

func _ready() -> void:
	add_to_group("resettable")
	_apply()

func _physics_process(_delta: float) -> void:
	var now := not get_overlapping_bodies().is_empty()
	if now != pressed:
		pressed = now
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
