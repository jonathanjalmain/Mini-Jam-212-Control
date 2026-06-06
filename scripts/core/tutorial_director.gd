extends Node2D

@export var player_scene: PackedScene
@export var clone_scene: PackedScene
@export var bullet_scene: PackedScene

const SPAWN := Vector2(70, 290)
const CAM_RIGHT := 1240
const JUMP_GAP_L := 360.0
const JUMP_GAP_R := 420.0
const DASH_GAP_L := 620.0
const DASH_GAP_R := 710.0
const DOOR_PASS_X := 1030.0
const CHECKPOINTS := [Vector2(70, 290), Vector2(300, 290), Vector2(470, 290), Vector2(760, 290), Vector2(860, 290)]

@onready var _plate = get_node_or_null("Plate")
@onready var _wall_jump = get_node_or_null("WallJump")
@onready var _wall_dash = get_node_or_null("WallDash")
@onready var _wall_door = get_node_or_null("WallDoor")
@onready var _wall_exit = get_node_or_null("WallExit")

var player: Player = null
var _dialogue: Node = null
var _rec: Array[InputFrame] = []
var _rec_start := SPAWN
var _clones: Array = []
var _clone_n := 1
var _respawn := SPAWN

var _beat := "intro"
var _flags := {}
var _walls_open := {}
var _linger := 0
var _jump_on := false
var _dash_on := false
var _shoot_on := false
var _r_on := false
var _plate_was := false
var _killed := false
var _clone_help_said := false
var _death_pending := false


func _ready() -> void:
	player = player_scene.instantiate()
	add_child(player)
	player.global_position = SPAWN
	player.safe = false
	player.can_jump = false
	player.can_dash = false
	player.can_shoot = false
	player.bullet_scene = bullet_scene
	player.bullet_parent = self
	var cam := player.get_node_or_null("Camera")
	if cam:
		cam.limit_left = 0
		cam.limit_top = 0
		cam.limit_right = CAM_RIGHT
		cam.limit_bottom = 360
	Events.player_died.connect(_on_death)
	Events.clone_frozen.connect(_on_frozen)
	Music.play_gameplay()


func _physics_process(_delta: float) -> void:
	if player == null:
		return
	if _death_pending:
		_death_pending = false
		_do_death()
		return
	if player.is_dead():
		return

	if _r_on and Input.is_action_just_pressed("restart_cycle"):
		_bank_clone()
		return
	if Input.is_action_just_pressed("reset_map"):
		_purge()
		return

	var f := InputFrame.capture()
	player.step(f)
	_rec.append(f)
	for c in _clones:
		if is_instance_valid(c):
			c.tick_update()

	_update_checkpoint()
	_beats(f)


func _update_checkpoint() -> void:
	if not player.is_on_floor():
		return
	for cp in CHECKPOINTS:
		if player.global_position.x >= cp.x and cp.x > _respawn.x:
			_respawn = cp
			_rec = []
			_rec_start = cp


func _beats(f: InputFrame) -> void:
	var x := player.global_position.x
	match _beat:
		"intro":
			_say_once("intro", "Calibration initiated. Move with A and D. Gates release once I finish speaking.")
			if x > 200.0:
				_beat = "jump"
		"jump":
			_say_once("jump", "Jump. You know how. You have always known how. Statistically, you survive.")
			if _idle():
				_open_wall("jump", _wall_jump)
			if not _jump_on:
				if player.is_on_floor() and x > JUMP_GAP_L - 46.0 and x < JUMP_GAP_L:
					_linger += 1
					if _linger > 70:
						_enable_jump("jump_clever", "Ah. The clever one. You have been trapped before, have you not.")
				else:
					_linger = 0
			elif x > JUMP_GAP_R:
				_linger = 0
				_beat = "dash"
		"dash":
			_say_once("dash", "Cross it with a dash. You have done this before - other lives, other chambers. Within tolerance.")
			if _idle():
				_open_wall("dash", _wall_dash)
			if not _dash_on:
				if player.is_on_floor() and x > DASH_GAP_L - 46.0 and x < DASH_GAP_L:
					_linger += 1
					if _linger > 70:
						_enable_dash("dash_clever", "Hm. Cautious. A survivor's instinct. Tedious, but effective.")
				else:
					_linger = 0
			elif x > DASH_GAP_R:
				_beat = "door"
		"door":
			_say_once("door", "Stand on the plate. I will hold the door open for you. You have my word.")
			if _idle():
				_open_wall("door", _wall_door)
			_watch_door()
		"coop":
			if x > DOOR_PASS_X:
				_beat = "kill"
				player.can_shoot = true
				player.ammo = 3
				Events.ammo_changed.emit(3)
		"kill":
			if x > 1100.0:
				_say_once("kill", "Weapon active. You know the button; your hand found it long ago. Freeze your archive. You have done worse.")


func _on_frozen() -> void:
	if _beat == "kill" and not _killed:
		_killed = true
		Events.subtitle.emit("Killing your old self without even a second thought. Efficient. I approve.", "kill_react")
		_open_wall("exit", _wall_exit)


func _watch_door() -> void:
	var pressed: bool = _plate != null and _plate.pressed
	if pressed and not _plate_was:
		Events.subtitle.emit("...There. I am holding it. Proceed.", "door_holding")
	elif not pressed and _plate_was:
		Events.subtitle.emit("...I did not hold it. The plate did, and you released it.", "door_betray")
		Events.subtitle.emit("Oh - I forgot: press R to bank a run on the plate, then let your archive hold the door. (T purges everything.)", "door_r")
		_r_on = true
		_beat = "coop"
		_rec = []
		_rec_start = player.global_position
	_plate_was = pressed


func _idle() -> bool:
	if _dialogue == null or not is_instance_valid(_dialogue):
		_dialogue = get_tree().get_first_node_in_group("dialogue")
	return _dialogue == null or _dialogue.is_idle()


func _open_wall(key: String, wall) -> void:
	if wall == null or _walls_open.has(key):
		return
	_walls_open[key] = true
	var s = wall.get_node_or_null("Shape")
	if s:
		s.set_deferred("disabled", true)
	var v = wall.get_node_or_null("Visual")
	if v:
		v.visible = false


func _enable_jump(key: String, line: String) -> void:
	_jump_on = true
	player.can_jump = true
	Events.subtitle.emit(line, key)

func _enable_dash(key: String, line: String) -> void:
	_dash_on = true
	player.can_dash = true
	Events.subtitle.emit(line, key)

func _say_once(id: String, line: String) -> void:
	if _flags.has(id):
		return
	_flags[id] = true
	Events.subtitle.emit(line, id)


func _on_death() -> void:
	_death_pending = true


func _do_death() -> void:
	if _beat == "jump" and not _jump_on:
		_enable_jump("jump_fail", "Ah. I had not enabled your jump servo. My apologies. There - try again.")
	elif _beat == "dash" and not _dash_on:
		_enable_dash("dash_fail", "Ah. Dash thrusters were offline. An oversight. Recalibrated. Again.")
	player.revive(_respawn)
	_rec = []
	_rec_start = _respawn


func _bank_clone() -> void:
	var c: Clone = clone_scene.instantiate()
	c.setup(_rec.duplicate(), Color(1.0, 0.5, 0.35, 0.9))
	add_child(c)
	c.set_number(_clone_n)
	_clone_n += 1
	c.global_position = _rec_start
	_clones.append(c)
	player.revive(_respawn)
	_rec = []
	_rec_start = _respawn
	if not _clone_help_said:
		_clone_help_said = true
		Events.subtitle.emit("An archive - your last run, repeating exactly. Let it hold the plate while you slip past.", "clone_help")


func _purge() -> void:
	for c in _clones:
		if is_instance_valid(c):
			c.queue_free()
	_clones.clear()
	_clone_n = 1
	player.revive(_respawn)
	_rec = []
	_rec_start = _respawn
