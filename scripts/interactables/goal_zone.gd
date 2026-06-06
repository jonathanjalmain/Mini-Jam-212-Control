extends Area2D

@export var base_color := Color(0.5, 1.0, 0.7)

var _done := false

@onready var _vis: Polygon2D = get_node_or_null("Visual")

func _ready() -> void:
	add_to_group("resettable")

func _physics_process(_delta: float) -> void:
	if _done:
		return
	for b in get_overlapping_bodies():
		if b.is_in_group("player") and b.carrying_item != null:
			_done = true
			Events.level_won.emit()
			return

func reset_state() -> void:
	_done = false
