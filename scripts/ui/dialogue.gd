extends CanvasLayer

const CPS := 38.0
const HOLD_BASE := 0.35
const HOLD_PER_CHAR := 0.012
const VOICE_DIR := "res://assets/voice/"

@onready var _box: ColorRect = $Root/Box
@onready var _text: Label = $Root/Box/Text
@onready var _tag: Label = $Root/Box/Tag
@onready var _voice: AudioStreamPlayer = get_node_or_null("Voice")

var _typing_sfx: AudioStreamPlayer
var _queue: Array = []
var _full := ""
var _shown := 0
var _accum := 0.0
var _hold := 0.0
var _typing := false

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	add_to_group("dialogue")
	_box.visible = false
	_typing_sfx = AudioStreamPlayer.new()
	_typing_sfx.bus = "SFX"
	_typing_sfx.volume_db = -18.0
	var tpath := "res://assets/soundEffect/typing.mp3"
	if ResourceLoader.exists(tpath):
		var s = load(tpath)
		if s is AudioStreamMP3:
			s.loop = true
		_typing_sfx.stream = s
	add_child(_typing_sfx)
	if _voice:
		_voice.bus = "Voice"
		_voice.volume_db = -3.0
	Events.subtitle.connect(say)

func say(text: String, voice: String = "") -> void:
	_queue.append({"text": text, "voice": voice})

func is_idle() -> bool:
	return not _typing and _hold <= 0.0 and not _voice_active() and _queue.is_empty()

func _voice_active() -> bool:
	return _voice != null and _voice.playing

func _process(delta: float) -> void:
	if _typing:
		_accum += delta * CPS
		while _shown < _full.length() and _accum >= 1.0:
			_shown += 1
			_accum -= 1.0
		_text.text = _full.substr(0, _shown)
		if _shown >= _full.length():
			_typing = false
			_hold = HOLD_BASE + float(_full.length()) * HOLD_PER_CHAR
			if _typing_sfx:
				_typing_sfx.stop()
		return

	if _hold > 0.0:
		_hold -= delta

	# Hold the bubble open until the read-time AND the voice clip are both done.
	if _hold <= 0.0 and not _voice_active():
		if _queue.is_empty():
			_box.visible = false
		else:
			_start_next()

func _start_next() -> void:
	var item: Dictionary = _queue.pop_front()
	_full = item["text"]
	_shown = 0
	_accum = 0.0
	_typing = true
	_box.visible = true
	_text.text = ""
	if _typing_sfx and _full.length() > 0:
		_typing_sfx.play()
	_play_voice(item.get("voice", ""))

func _play_voice(key: String) -> void:
	if _voice == null:
		return
	_voice.stop()
	if key == "":
		return
	var path := VOICE_DIR + key + ".mp3"
	if ResourceLoader.exists(path):
		_voice.stream = load(path)
		_voice.play()
