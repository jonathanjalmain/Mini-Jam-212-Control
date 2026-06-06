extends Area2D

# A gate that lets the FIRST body (player or clone) pass through once,
# then seals shut (solid) for the rest of the cycle. Resets open each cycle.

@export var open_color := Color(0.65, 0.45, 1.0, 0.22)
@export var closed_color := Color(0.72, 0.5, 1.0, 0.95)

var _used := false
var _passer: Node = null
var _shape: CollisionShape2D
var _fill: Polygon2D

func _ready() -> void:
	add_to_group("resettable")
	body_entered.connect(_on_enter)
	body_exited.connect(_on_exit)
	reset_state()

func _on_enter(body: Node) -> void:
	if _used:
		return
	if body.is_in_group("player") or body.is_in_group("clones"):
		_used = true
		_passer = body

func _on_exit(body: Node) -> void:
	if _used and body == _passer:
		_close()

func _close() -> void:
	if _shape == null:
		_shape = get_node_or_null("Barrier/BShape")
	if _shape:
		_shape.set_deferred("disabled", false)
	_set_fill(closed_color)

func _set_fill(c: Color) -> void:
	if _fill == null:
		_fill = get_node_or_null("Fill")
	if _fill:
		_fill.color = c

func reset_state() -> void:
	_used = false
	_passer = null
	if _shape == null:
		_shape = get_node_or_null("Barrier/BShape")
	if _shape:
		_shape.set_deferred("disabled", true)
	_set_fill(open_color)
