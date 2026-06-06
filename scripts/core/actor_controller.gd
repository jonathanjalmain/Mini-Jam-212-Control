class_name ActorController
extends CharacterBody2D

const FIXED_DT := 1.0 / 60.0

@export_group("Movement")
@export var speed := 140.0
@export var accel := 1400.0
@export var friction := 1800.0
@export var gravity := 980.0
@export var max_fall := 540.0
@export var jump_velocity := -330.0
@export var coyote_ticks := 6
@export var jump_buffer_ticks := 6

@export_group("Dash")
@export var dash_speed := 340.0
@export var dash_ticks := 10
@export var dash_cooldown_ticks := 36

@export_group("Shooting")
@export var muzzle_offset := 11.0
@export var bullet_speed := 360.0

var bullet_scene: PackedScene = null
var bullet_parent: Node = null
var carrying_item: Node = null

var can_jump := true
var can_dash := true
var can_shoot := true

var facing := 1
@onready var _facing_visual: Node2D = get_node_or_null("Visual")
var _prev_jump := false
var _prev_dash := false
var _prev_shoot := false
var _coyote := 0
var _jump_buffer := 0
var _dash_timer := 0
var _dash_cd := 0
var _dashing := false


func step(f: InputFrame) -> void:
	var dir := (1 if f.right else 0) - (1 if f.left else 0)
	if dir != 0:
		facing = dir
		if _facing_visual:
			_facing_visual.scale.x = facing

	var jump_just := f.jump and not _prev_jump
	var dash_just := f.dash and not _prev_dash
	var shoot_just := f.shoot and not _prev_shoot
	_prev_jump = f.jump
	_prev_dash = f.dash
	_prev_shoot = f.shoot

	if is_on_floor():
		_coyote = coyote_ticks
	elif _coyote > 0:
		_coyote -= 1

	if jump_just:
		_jump_buffer = jump_buffer_ticks
	elif _jump_buffer > 0:
		_jump_buffer -= 1

	if _dash_cd > 0:
		_dash_cd -= 1

	var dash_allowed := can_dash and not f.carrying
	if dash_just and dash_allowed and not _dashing and _dash_cd <= 0:
		_dashing = true
		_dash_timer = dash_ticks
		_dash_cd = dash_cooldown_ticks
		var ddir := dir if dir != 0 else facing
		velocity.x = ddir * dash_speed
		velocity.y = 0.0
		_sfx_dash()

	if _dashing:
		_dash_timer -= 1
		velocity.y = 0.0
		if _dash_timer <= 0:
			_dashing = false
	else:
		velocity.y = min(velocity.y + gravity * FIXED_DT, max_fall)
		var target := dir * speed
		if dir != 0:
			velocity.x = move_toward(velocity.x, target, accel * FIXED_DT)
		else:
			velocity.x = move_toward(velocity.x, 0.0, friction * FIXED_DT)
		if _jump_buffer > 0 and _coyote > 0 and can_jump:
			var jv := jump_velocity
			if f.carrying:
				jv *= 0.72
			velocity.y = jv
			_jump_buffer = 0
			_coyote = 0
			_sfx_jump()

	if shoot_just and can_shoot and _can_shoot():
		_do_shoot()

	move_and_slide()
	_sfx_walk(dir != 0 and not _dashing and is_on_floor())


func is_dashing() -> bool:
	return _dashing


func reset_movement() -> void:
	velocity = Vector2.ZERO
	_dashing = false
	_dash_timer = 0
	_dash_cd = 0
	_coyote = 0
	_jump_buffer = 0
	_prev_jump = false
	_prev_dash = false
	_prev_shoot = false


func _sfx_jump() -> void:
	pass

func _sfx_dash() -> void:
	pass

func _sfx_walk(_active: bool) -> void:
	pass


func _can_shoot() -> bool:
	return false


func _do_shoot() -> void:
	if bullet_scene == null or bullet_parent == null:
		return
	var b := bullet_scene.instantiate()
	bullet_parent.add_child(b)
	b.global_position = global_position + Vector2(facing * muzzle_offset, -2.0)
	b.setup(facing, bullet_speed, self)
