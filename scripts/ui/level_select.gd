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
	{"name": "CHAMBER 10", "path": "res://scenes/main/Chamber10.tscn"},
	{"name": "CHAMBER 11", "path": "res://scenes/main/Chamber11.tscn"},
	{"name": "MAIN MENU", "path": "res://scenes/main/MainMenu.tscn"},
]

@onready var _list: RichTextLabel = $Root/List

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
		if not _is_unlocked(_sel):
			return
		get_tree().change_scene_to_file(str(LEVELS[_sel]["path"]))

func _is_unlocked(i: int) -> bool:
	if Progress.UNLOCK_ALL:
		return true
	var path := str(LEVELS[i]["path"])
	if path.ends_with("MainMenu.tscn") or path.ends_with("Tutorial.tscn"):
		return true
	if i <= 1:
		return true
	return Progress.is_completed(str(LEVELS[i - 1]["path"]))

func _refresh() -> void:
	var cur_on := fmod(_blink, 1.0) < 0.5
	var n := LEVELS.size()
	var rows := int(ceil(n / 2.0))
	var out := ""
	for r in range(rows):
		var line := _cell(r, n, cur_on, 32)
		if r >= 1:
			line += _cell(r - 1 + rows, n, cur_on, 0)
		out += line + "\n"
	_list.text = out

func _cell(i: int, n: int, cur_on: bool, pad: int) -> String:
	if i < 0 or i >= n:
		return "".rpad(pad)
	var nm := str(LEVELS[i]["name"])
	var unlocked := _is_unlocked(i)
	var vis: String
	if i == _sel:
		vis = "> " + nm + (" <" if cur_on else "")
	elif unlocked:
		vis = "  " + nm
	else:
		vis = "x " + nm
	if pad > 0:
		vis = vis.rpad(pad)
	var col := "5cffa0"
	if not unlocked:
		col = "37624a"
	elif i == _sel:
		col = "d6ffe6"
	return "[color=#%s]%s[/color]" % [col, vis]
