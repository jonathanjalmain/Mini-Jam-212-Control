class_name Player
extends ActorController

var loop_manager: Node = null
var ammo := 0
var safe := true
var _dead := false

@onready var _hurtbox: Area2D = $Hurtbox
@onready var _num: Label = get_node_or_null("Num")

func _ready() -> void:
	add_to_group("player")

func set_number(n: int) -> void:
	if _num:
		_num.text = "%02d" % n


func _can_shoot() -> bool:
	return ammo > 0


func _do_shoot() -> void:
	super._do_shoot()
	ammo -= 1
	Events.ammo_changed.emit(ammo)


func check_lethal() -> void:
	if _dead or safe:
		return
	for b in _hurtbox.get_overlapping_bodies():
		if b.is_in_group("clones") and not b.frozen:
			die()
			return


func die() -> void:
	if _dead or safe:
		return
	_dead = true
	Events.player_died.emit()
	if loop_manager:
		loop_manager.on_player_died()


func reset_to_spawn(pos: Vector2, ammo_count: int) -> void:
	global_position = pos
	reset_movement()
	_dead = false
	safe = true
	carrying_item = null
	ammo = ammo_count
	Events.ammo_changed.emit(ammo)

func revive(pos: Vector2) -> void:
	global_position = pos
	reset_movement()
	_dead = false
	safe = false
	carrying_item = null

func is_dead() -> bool:
	return _dead
