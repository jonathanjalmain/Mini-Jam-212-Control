class_name SettingsMenu
extends CanvasLayer

const STEP := 0.1

static var return_scene := "res://scenes/main/MainMenu.tscn"

@onready var _list: Label = $Root/List

var _rows := ["Master", "Ambience", "SFX", "Voice"]
var _sel := 0

func _ready() -> void:
	Music.play_menu()
	_refresh()

func _input(event: InputEvent) -> void:
	var n := _rows.size() + 1
	if event.is_action_pressed("ui_down"):
		_sel = (_sel + 1) % n
		_refresh()
	elif event.is_action_pressed("ui_up"):
		_sel = (_sel - 1 + n) % n
		_refresh()
	elif event.is_action_pressed("ui_left"):
		_adjust(-STEP)
	elif event.is_action_pressed("ui_right"):
		_adjust(STEP)
	elif event.is_action_pressed("ui_accept"):
		if _sel == _rows.size():
			get_tree().change_scene_to_file(return_scene)

func _adjust(d: float) -> void:
	if _sel < _rows.size():
		var bus: String = _rows[_sel]
		Audio.set_linear(bus, clampf(Audio.get_linear(bus) + d, 0.0, 1.0))
		_refresh()

func _refresh() -> void:
	var lines: Array[String] = []
	for i in range(_rows.size()):
		var v := Audio.get_linear(_rows[i])
		var filled := clampi(int(round(v * 10.0)), 0, 10)
		var bar := "[" + "#".repeat(filled) + "-".repeat(10 - filled) + "]"
		var cur := "> " if i == _sel else "  "
		lines.append(cur + _rows[i].rpad(10) + bar + "  " + str(int(round(v * 100.0))) + "%")
	lines.append("")
	lines.append(("> " if _sel == _rows.size() else "  ") + "BACK")
	_list.text = "\n".join(lines)
