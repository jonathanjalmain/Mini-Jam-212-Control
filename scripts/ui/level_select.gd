extends CanvasLayer

const LEVELS := [
	{"name": "TUTORIAL  //  CALIBRATION", "path": "res://scenes/main/Tutorial.tscn"},
	{"name": "CHAMBER 01", "path": "res://scenes/main/Main.tscn"},
	{"name": "CHAMBER 02", "path": "res://scenes/main/Chamber02.tscn"},
	{"name": "CHAMBER 03", "path": "res://scenes/main/Chamber03.tscn"},
	{"name": "CHAMBER 04", "path": "res://scenes/main/Chamber04.tscn"},
	{"name": "CHAMBER 05", "path": "res://scenes/main/Chamber05.tscn"},
	{"name": "CHAMBER 06", "path": "res://scenes/main/Chamber06.tscn"},
	{"name": "CHAMBER 07", "path": "res://scenes/main/Chamber07.tscn"},
	{"name": "CHAMBER 08", "path": "res://scenes/main/Chamber08.tscn"},
	{"name": "CHAMBER 09", "path": "res://scenes/main/Chamber09.tscn"},
	{"name": "MAIN MENU", "path": "res://scenes/main/MainMenu.tscn"},
]

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
		_sel = (_sel + 1) % LEVELS.size()
	elif event.is_action_pressed("ui_up"):
		_sel = (_sel - 1 + LEVELS.size()) % LEVELS.size()
	elif event.is_action_pressed("ui_accept"):
		var path: String = LEVELS[_sel]["path"]
		if path.ends_with("Settings.tscn"):
			SettingsMenu.return_scene = "res://scenes/main/LevelSelect.tscn"
		get_tree().change_scene_to_file(path)

func _refresh() -> void:
	var cursor := " <" if fmod(_blink, 1.0) < 0.5 else "  "
	var lines: Array[String] = []
	for i in range(LEVELS.size()):
		if i == _sel:
			lines.append("  > " + str(LEVELS[i]["name"]) + cursor)
		else:
			lines.append("    " + str(LEVELS[i]["name"]))
	_list.text = "\n".join(lines)
