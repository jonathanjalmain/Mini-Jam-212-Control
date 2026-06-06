extends CanvasLayer

const OPTIONS := ["START", "SELECT CHAMBER", "SETTINGS", "QUIT"]

@onready var _list: Label = $Root/List

var _sel := 0
var _blink := 0.0

func _ready() -> void:
	Music.play_menu()
	_refresh()

func _process(delta: float) -> void:
	_blink += delta
	_refresh()

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_down"):
		_sel = (_sel + 1) % OPTIONS.size()
	elif event.is_action_pressed("ui_up"):
		_sel = (_sel - 1 + OPTIONS.size()) % OPTIONS.size()
	elif event.is_action_pressed("ui_accept"):
		_select()

func _select() -> void:
	match OPTIONS[_sel]:
		"START":
			get_tree().change_scene_to_file("res://scenes/main/Tutorial.tscn")
		"SELECT CHAMBER":
			get_tree().change_scene_to_file("res://scenes/main/LevelSelect.tscn")
		"SETTINGS":
			SettingsMenu.return_scene = "res://scenes/main/MainMenu.tscn"
			get_tree().change_scene_to_file("res://scenes/main/Settings.tscn")
		"QUIT":
			get_tree().quit()

func _refresh() -> void:
	var cursor := " <" if fmod(_blink, 1.0) < 0.5 else "  "
	var lines: Array[String] = []
	for i in range(OPTIONS.size()):
		if i == _sel:
			lines.append("  > " + OPTIONS[i] + cursor)
		else:
			lines.append("    " + OPTIONS[i])
	_list.text = "\n".join(lines)
