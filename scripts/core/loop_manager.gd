class_name LoopManager
extends Node2D

@export var levels: Array[PackedScene] = []
@export var player_scene: PackedScene
@export var clone_scene: PackedScene
@export var bullet_scene: PackedScene
@export_file("*.tscn") var win_scene := "res://scenes/main/LevelSelect.tscn"

var level_index := 0
var level: Node = null
var player: Player = null

var recorder := Recorder.new()
var clone_recordings: Array = []

var current_tick := 0
var resets_used := 0
var cycle_duration_ticks := 600
var max_resets := 30
var bullets_per_map := 2

var _end_requested := false
var _won := false


func _ready() -> void:
	if levels.is_empty():
		push_error("LoopManager: no levels assigned")
		return
	Events.level_won.connect(_on_level_won)
	Music.play_gameplay()
	load_level(level_index)


func _on_level_won() -> void:
	if _won:
		return
	_won = true
	var cur := get_tree().current_scene
	if cur:
		Progress.mark(cur.scene_file_path)
	Events.log_line.emit("OBJECTIVE COMPLETE // SUBJECT RELEASED")
	get_tree().create_timer(1.8).timeout.connect(_go_to_select)


func _go_to_select() -> void:
	get_tree().change_scene_to_file(win_scene)


func load_level(idx: int) -> void:
	if level:
		level.queue_free()
	clone_recordings.clear()
	resets_used = 0
	_won = false
	level_index = idx
	level = levels[idx].instantiate()
	add_child(level)
	cycle_duration_ticks = level.cycle_duration_ticks
	max_resets = level.max_resets
	bullets_per_map = level.bullets_per_map
	_spawn_player()
	player.set_ammo(bullets_per_map)
	_reset_cycle_state()
	Events.cycle_changed.emit(1, max_resets)


func _spawn_player() -> void:
	player = player_scene.instantiate()
	player.loop_manager = self
	player.bullet_scene = bullet_scene
	player.bullet_parent = level
	level.add_child(player)
	var cam := player.get_node_or_null("Camera")
	if cam:
		cam.limit_left = level.cam_left
		cam.limit_top = level.cam_top
		cam.limit_right = level.cam_right
		cam.limit_bottom = level.cam_bottom


func _physics_process(_delta: float) -> void:
	if Input.is_action_just_pressed("reset_map"):
		reset_map_full()
		return
	if _won or level == null or player == null:
		return
	if Input.is_action_just_pressed("restart_cycle"):
		Events.log_line.emit("CYCLE TERMINATED // SUBJECT REQUEST")
		Events.cycle_restarted.emit()
		end_cycle()
		return

	current_tick += 1
	var f := InputFrame.capture()
	f.carrying = player.carrying_item != null
	player.step(f)
	recorder.record(f)

	for c in get_tree().get_nodes_in_group("clones"):
		c.tick_update()

	player.check_lethal()

	if level.no_timer:
		Events.timer_changed.emit(1.0)
	else:
		Events.timer_changed.emit(1.0 - float(current_tick) / float(cycle_duration_ticks))

	var timed_out: bool = not level.no_timer and current_tick >= cycle_duration_ticks
	if _end_requested or timed_out:
		end_cycle()


func on_player_died() -> void:
	_end_requested = true


func end_cycle() -> void:
	_end_requested = false
	clone_recordings.append(recorder.get_recording())
	resets_used += 1
	if resets_used >= max_resets:
		reset_map_full()
		return
	_reset_cycle_state()
	Events.cycle_changed.emit(resets_used + 1, max_resets - resets_used)


func reset_map_full() -> void:
	clone_recordings.clear()
	resets_used = 0
	_won = false
	_reset_cycle_state()
	player.set_ammo(bullets_per_map)
	for n in get_tree().get_nodes_in_group("item"):
		if n.has_method("reset_state"):
			n.reset_state()
	Events.map_reset.emit()
	Events.cycle_changed.emit(1, max_resets)


func _reset_cycle_state() -> void:
	current_tick = 0
	recorder.reset()
	_clear_group("bullets")
	_clear_group("clones")
	for n in get_tree().get_nodes_in_group("resettable"):
		if n.has_method("reset_state"):
			n.reset_state()
	player.reset_to_spawn(level.spawn_pad.global_position)
	player.set_number(resets_used + 1)
	_spawn_clones()


func _clear_group(group: String) -> void:
	for n in get_tree().get_nodes_in_group(group):
		n.remove_from_group(group)
		n.queue_free()


func _spawn_clones() -> void:
	var n := clone_recordings.size()
	for i in range(n):
		var c := clone_scene.instantiate()
		c.setup(clone_recordings[i], _clone_color(i, n))
		c.bullet_scene = bullet_scene
		c.bullet_parent = level
		c.ammo = bullets_per_map
		level.add_child(c)
		c.set_number(i + 1)
		c.global_position = level.spawn_pad.global_position
	if n > 0:
		Events.clone_spawned.emit(n)


func _clone_color(i: int, n: int) -> Color:
	var hue := fposmod(0.035 * float(i), 0.11)
	var col := Color.from_hsv(hue, 0.72, 1.0)
	col.a = lerp(0.45, 0.95, float(i + 1) / float(max(n, 1)))
	return col
