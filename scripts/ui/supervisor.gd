extends CanvasLayer

const EYE_POS := Vector2(320, 46)
const PUPIL_RANGE := Vector2(7.0, 4.0)
const COLOR_IDLE := Color(0.45, 1.0, 0.63)
const COLOR_ALERT := Color(1.0, 0.35, 0.3)

@onready var _eye: Node2D = $Eye
@onready var _iris: Polygon2D = $Eye/Iris
@onready var _pupil: Polygon2D = $Eye/Pupil
@onready var _flash: ColorRect = $Flash

var _player: Node = null


func _ready() -> void:
	_iris.color = COLOR_IDLE
	Events.cycle_changed.connect(_on_cycle)
	Events.player_died.connect(_on_died)
	Events.map_reset.connect(_on_purge)
	Events.clone_frozen.connect(_on_frozen)
	_idle_blink_loop()


func _process(_delta: float) -> void:
	if _player == null or not is_instance_valid(_player):
		_player = get_tree().get_first_node_in_group("player")
	if _player:
		var tx := clampf((_player.global_position.x - EYE_POS.x) / 320.0, -1.0, 1.0)
		var ty := clampf((_player.global_position.y - 200.0) / 200.0, -1.0, 1.0)
		var target := Vector2(tx * PUPIL_RANGE.x, ty * PUPIL_RANGE.y)
		_pupil.position = _pupil.position.lerp(target, 0.18)


func _idle_blink_loop() -> void:
	while is_inside_tree():
		await get_tree().create_timer(randf_range(2.5, 5.5)).timeout
		if is_inside_tree():
			_blink()


func _blink() -> void:
	var tw := create_tween()
	tw.tween_property(_eye, "scale:y", 0.12, 0.05)
	tw.tween_property(_eye, "scale:y", 1.0, 0.09)


func _flash_screen(col: Color, a: float) -> void:
	_flash.color = Color(col.r, col.g, col.b, a)
	var tw := create_tween()
	tw.tween_property(_flash, "color:a", 0.0, 0.35)


func _set_alert(on: bool) -> void:
	_iris.color = COLOR_ALERT if on else COLOR_IDLE


func _on_cycle(cycle: int, _resets_left: int) -> void:
	_blink()
	_flash_screen(COLOR_IDLE, 0.16)
	_set_alert(false)
	if cycle <= 1:
		Events.log_line.emit("SYSTEM ONLINE")
		Events.log_line.emit("SUBJECT INSERTED // RETRIEVE + RETURN")
	else:
		Events.log_line.emit("RUN %02d ARCHIVED // SPECIMENS: %d" % [cycle - 1, cycle - 1])
		if cycle == 2:
			Events.log_line.emit("ARCHIVE 01 ACTIVE // IT REPEATS YOU // AVOID CONTACT")


func _on_died() -> void:
	_set_alert(true)
	_flash_screen(COLOR_ALERT, 0.42)
	Events.log_line.emit("SUBJECT TERMINATED // CAUSE: SELF")


func _on_purge() -> void:
	_flash_screen(Color(1, 1, 1), 0.5)
	Events.log_line.emit("FULL PURGE // ARCHIVES CLEARED")


func _on_frozen() -> void:
	Events.log_line.emit("ARCHIVE UNIT CRYSTALLIZED")
