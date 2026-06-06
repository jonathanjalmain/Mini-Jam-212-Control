class_name Player
extends ActorController

var loop_manager: Node = null
var ammo := 0
var safe := true
var _dead := false

const SFX_DIR := "res://assets/soundEffect/"

@onready var _hurtbox: Area2D = $Hurtbox
@onready var _num: Label = get_node_or_null("Num")

var _sfx_jump_p: AudioStreamPlayer
var _sfx_dash_p: AudioStreamPlayer
var _sfx_shot_p: AudioStreamPlayer
var _sfx_walk_p: AudioStreamPlayer

func _ready() -> void:
	add_to_group("player")
	_sfx_jump_p = _make_sfx("jump", false, -10.0)
	_sfx_dash_p = _make_sfx("dash", false, -10.0)
	_sfx_shot_p = _make_sfx("shot", false, -8.0)
	_sfx_walk_p = _make_sfx("walk", true, -18.0)

func _make_sfx(name: String, looping: bool, db: float) -> AudioStreamPlayer:
	var p := AudioStreamPlayer.new()
	p.bus = "SFX"
	p.volume_db = db
	var path := SFX_DIR + name + ".mp3"
	if ResourceLoader.exists(path):
		var s = load(path)
		if looping and s is AudioStreamMP3:
			s.loop = true
		p.stream = s
	add_child(p)
	return p

func _sfx_jump() -> void:
	if _sfx_jump_p:
		_sfx_jump_p.play()

func _sfx_dash() -> void:
	if _sfx_dash_p:
		_sfx_dash_p.play()

func _sfx_walk(active: bool) -> void:
	if _sfx_walk_p == null:
		return
	if active and not _sfx_walk_p.playing:
		_sfx_walk_p.play()
	elif not active and _sfx_walk_p.playing:
		_sfx_walk_p.stop()

func set_number(n: int) -> void:
	if _num:
		_num.text = "%02d" % n


func _can_shoot() -> bool:
	return ammo > 0


func _do_shoot() -> void:
	super._do_shoot()
	ammo -= 1
	Events.ammo_changed.emit(ammo)
	if _sfx_shot_p:
		_sfx_shot_p.play()


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


func reset_to_spawn(pos: Vector2) -> void:
	global_position = pos
	reset_movement()
	_dead = false
	safe = true
	carrying_item = null

func set_ammo(n: int) -> void:
	ammo = n
	Events.ammo_changed.emit(ammo)

func revive(pos: Vector2) -> void:
	global_position = pos
	reset_movement()
	_dead = false
	safe = false
	carrying_item = null

func is_dead() -> bool:
	return _dead
