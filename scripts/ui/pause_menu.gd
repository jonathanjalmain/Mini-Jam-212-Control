extends CanvasLayer

const OPTS := ["RESUME", "RESTART CHAMBER", "SELECT CHAMBER", "MAIN MENU"]

var _open := false
var _sel := 0
var _blink := 0.0

@onready var _panel: Control = $Panel
@onready var _opts_label: Label = $Panel/Options

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	_panel.visible = false

func _is_gameplay() -> bool:
	var cs := get_tree().current_scene
	if cs == null:
		return false
	var p := cs.scene_file_path
	return p.contains("/Chamber") or p.ends_with("/Main.tscn") or p.ends_with("/Tutorial.tscn")

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("pause"):
		if _open:
			_close()
		elif _is_gameplay():
			_open_menu()
		get_viewport().set_input_as_handled()
		return
	if not _open:
		return
	if event.is_action_pressed("ui_down"):
		_sel = (_sel + 1) % OPTS.size()
	elif event.is_action_pressed("ui_up"):
		_sel = (_sel - 1 + OPTS.size()) % OPTS.size()
	elif event.is_action_pressed("ui_accept"):
		_activate()

func _open_menu() -> void:
	_open = true
	_sel = 0
	_panel.visible = true
	get_tree().paused = true

func _close() -> void:
	_open = false
	_panel.visible = false
	get_tree().paused = false

func _activate() -> void:
	match _sel:
		0:
			_close()
		1:
			_close()
			get_tree().reload_current_scene()
		2:
			_close()
			get_tree().change_scene_to_file("res://scenes/main/LevelSelect.tscn")
		3:
			_close()
			get_tree().change_scene_to_file("res://scenes/main/MainMenu.tscn")

func _process(delta: float) -> void:
	if not _open:
		return
	_blink += delta
	var cur := " <" if fmod(_blink, 1.0) < 0.5 else ""
	var lines: Array[String] = []
	for i in range(OPTS.size()):
		if i == _sel:
			lines.append("> " + OPTS[i] + cur)
		else:
			lines.append("  " + OPTS[i])
	_opts_label.text = "\n".join(lines)
