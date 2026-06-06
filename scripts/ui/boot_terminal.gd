extends CanvasLayer

const CPS := 24.0

const LINES := [
	"CONTROL SYSTEM v4.06  ---  ONLINE",
	"CHRONO-CHAMBER 01 .......... STABILIZED",
	"SUBJECT 00 ................. ACQUIRED",
	"",
	"DIRECTIVE:",
	"  RETRIEVE THE CORE.",
	"  RETURN IT TO ENTRY.",
	"",
	"PARAMETERS:",
	"  THE CHAMBER RESETS EACH CYCLE.",
	"  FAILED RUNS ARE ARCHIVED.",
	"  ARCHIVES ARE REINSTATED. THEY REPEAT YOU.",
	"  CONTACT WITH AN ARCHIVE IS FATAL.",
	"",
	"  YOU ARE THE VARIABLE.",
	"  YOU ARE ALSO THE OBSTACLE.",
	"",
	"BEGIN.",
]

@onready var _text: Label = $Root/Text
@onready var _prompt: Label = $Root/Prompt
@onready var _bg: ColorRect = $Root/Bg

var _full := ""
var _shown := 0
var _char_accum := 0.0
var _done := false
var _glitch_accum := 0.0
var _blink := 0.0
var _typing_sfx: AudioStreamPlayer

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	get_tree().paused = true
	_full = "\n".join(LINES)
	_text.text = ""
	_prompt.visible = false
	_typing_sfx = AudioStreamPlayer.new()
	_typing_sfx.bus = "SFX"
	_typing_sfx.volume_db = -14.0
	var tpath := "res://assets/soundEffect/typing2.mp3"
	if ResourceLoader.exists(tpath):
		var s = load(tpath)
		if s is AudioStreamMP3:
			s.loop = true
		_typing_sfx.stream = s
	add_child(_typing_sfx)
	_typing_sfx.play()

func _process(delta: float) -> void:
	if _done and _typing_sfx and _typing_sfx.playing:
		_typing_sfx.stop()
	if not _done:
		_char_accum += delta * CPS
		while _shown < _full.length() and _char_accum >= 1.0:
			_shown += 1
			_char_accum -= 1.0
		_text.text = _full.substr(0, _shown)
		if _shown >= _full.length():
			_done = true
			_prompt.visible = true

	_glitch_accum += delta
	if _glitch_accum > 0.07:
		_glitch_accum = 0.0
		if randf() < 0.32:
			_text.position = Vector2(randf_range(-1.5, 1.5), randf_range(-1.0, 1.0))
		else:
			_text.position = Vector2.ZERO
		_bg.color = Color(0.02, 0.06, 0.04, 1) if randf() < 0.12 else Color(0.035, 0.045, 0.04, 1)

	if _done:
		_blink += delta
		_prompt.modulate.a = 0.35 + 0.45 * (sin(_blink * 6.0) * 0.5 + 0.5)

func _input(event: InputEvent) -> void:
	var go: bool = (event is InputEventKey and event.pressed and not event.echo) \
		or (event is InputEventMouseButton and event.pressed)
	if not go:
		return
	if not _done:
		_shown = _full.length()
		_text.text = _full
		_done = true
		_prompt.visible = true
	else:
		_finish()

func _finish() -> void:
	get_tree().paused = false
	queue_free()
