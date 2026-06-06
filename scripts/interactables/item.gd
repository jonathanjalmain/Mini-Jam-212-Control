extends Area2D

@export var base_color := Color(1.0, 0.95, 0.6)

var _carrier: Node = null
var _home := Vector2.ZERO

@onready var _vis: Polygon2D = get_node_or_null("Visual")

func _ready() -> void:
	add_to_group("item")
	_home = global_position
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node) -> void:
	if _carrier == null and body.is_in_group("player"):
		_carrier = body
		body.carrying_item = self
		Events.log_line.emit("CORE ACQUIRED :: RETURN TO ENTRY")

func _physics_process(_delta: float) -> void:
	if _carrier and is_instance_valid(_carrier):
		if _carrier.carrying_item != self:
			_carrier = null
			return
		global_position = _carrier.global_position + Vector2(0, -6)

func reset_state() -> void:
	if _carrier and is_instance_valid(_carrier):
		_carrier.carrying_item = null
	_carrier = null
	global_position = _home
