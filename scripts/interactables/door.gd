extends StaticBody2D

@export var inverted := false
@export var base_color := Color(1.0, 0.72, 0.2)

var _open := false

@onready var _shape: CollisionShape2D = $Shape
@onready var _vis: Polygon2D = get_node_or_null("Visual")

func _ready() -> void:
	add_to_group("resettable")
	reset_state()

func set_active(on: bool) -> void:
	_open = on if not inverted else not on
	_apply()

func _apply() -> void:
	_shape.set_deferred("disabled", _open)
	if _vis:
		_vis.color = Color(base_color.r, base_color.g, base_color.b, 0.1 if _open else 0.95)

func reset_state() -> void:
	set_active(false)
