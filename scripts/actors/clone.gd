class_name Clone
extends ActorController

const LAYER_CLONE := 4
const LAYER_FROZEN := 8

var frames: Array[InputFrame] = []
var replay_tick := 0
var frozen := false
var dead := false
var ammo := 0
var _pending_color := Color.WHITE

@onready var _visual: Node2D = $Visual
@onready var _trail: Line2D = get_node_or_null("Trail")
@onready var _num: Label = get_node_or_null("Num")

var number := 0

func setup(recording: Array[InputFrame], color: Color) -> void:
	frames = recording
	_pending_color = color

func set_number(n: int) -> void:
	number = n
	if _num:
		_num.text = "%02d" % n
		_num.modulate = Color(_pending_color.r, _pending_color.g, _pending_color.b, 1.0)

func _ready() -> void:
	add_to_group("clones")
	if _visual:
		_visual.modulate = _pending_color
	if _trail:
		_trail.modulate = Color(_pending_color.r, _pending_color.g, _pending_color.b, 0.6)


func tick_update() -> void:
	if frozen or dead:
		return
	step(_next_frame())


func die() -> void:
	if dead or frozen:
		return
	dead = true
	remove_from_group("clones")
	queue_free()


func _next_frame() -> InputFrame:
	if replay_tick < frames.size():
		var f := frames[replay_tick]
		replay_tick += 1
		return f
	return InputFrame.empty()


func _can_shoot() -> bool:
	return not frozen and ammo > 0


func _do_shoot() -> void:
	super._do_shoot()
	ammo -= 1


func freeze() -> void:
	if frozen:
		return
	frozen = true
	carrying_item = null
	velocity = Vector2.ZERO
	collision_layer = LAYER_FROZEN
	if _visual:
		_visual.modulate = Color(0.62, 0.70, 0.82, 1.0)
	if _trail:
		_trail.modulate = Color(0.62, 0.70, 0.82, 0.4)
	Events.clone_frozen.emit()
