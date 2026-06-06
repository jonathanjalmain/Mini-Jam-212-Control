extends Area2D

const FIXED_DT := 1.0 / 60.0
const GRAVITY := 980.0
const MAX_FALL := 540.0
const HALF_H := 7.0

@export var base_color := Color(1.0, 0.95, 0.6)

var _carrier: Node = null
var _home := Vector2.ZERO
var _vel_y := 0.0

@onready var _vis: Polygon2D = get_node_or_null("Visual")

func _ready() -> void:
	add_to_group("item")
	_home = global_position
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node) -> void:
	if _carrier != null:
		return
	if body.is_in_group("clones"):
		if not body.frozen:
			_carrier = body
			body.carrying_item = self
	elif body.is_in_group("player"):
		_carrier = body
		body.carrying_item = self
		Events.log_line.emit("CORE ACQUIRED :: RETURN TO ENTRY")

func _physics_process(_delta: float) -> void:
	if _carrier and is_instance_valid(_carrier) and _carrier.carrying_item == self:
		global_position = _carrier.global_position + Vector2(0, -6)
		_vel_y = 0.0
		return
	_carrier = null
	_fall()

func _fall() -> void:
	_vel_y = min(_vel_y + GRAVITY * FIXED_DT, MAX_FALL)
	var step := _vel_y * FIXED_DT
	var space := get_world_2d().direct_space_state
	var to := global_position + Vector2(0, step + HALF_H)
	var q := PhysicsRayQueryParameters2D.create(global_position, to, 1)
	var hit := space.intersect_ray(q)
	if hit:
		global_position.y = hit.position.y - HALF_H
		_vel_y = 0.0
	else:
		global_position.y += step

func reset_state() -> void:
	if _carrier and is_instance_valid(_carrier):
		_carrier.carrying_item = null
	_carrier = null
	_vel_y = 0.0
	global_position = _home
