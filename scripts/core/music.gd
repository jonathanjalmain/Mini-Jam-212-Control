extends Node

const GAMEPLAY := "res://assets/soundEffect/labBackground.mp3"
const MENU := "res://assets/soundEffect/oldComputerFan.mp3"
const GAMEPLAY_DB := -14.0
const MENU_DB := -18.0

var _player: AudioStreamPlayer
var _current := ""

func _ready() -> void:
	_player = AudioStreamPlayer.new()
	_player.bus = "Ambience"
	add_child(_player)

func play_gameplay() -> void:
	_play(GAMEPLAY, GAMEPLAY_DB)

func play_menu() -> void:
	_play(MENU, MENU_DB)

func _play(path: String, db: float) -> void:
	if _current == path and _player.playing:
		return
	_current = path
	if not ResourceLoader.exists(path):
		return
	var s = load(path)
	if s is AudioStreamMP3:
		s.loop = true
	_player.stream = s
	_player.volume_db = db
	_player.play()

func stop() -> void:
	_current = ""
	_player.stop()
