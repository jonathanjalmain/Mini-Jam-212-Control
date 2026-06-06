extends CanvasLayer

const TIMER_FULL_WIDTH := 200.0
const MAX_LINES := 4

@onready var _cycle: Label = $Root/Cycle
@onready var _ammo: Label = $Root/Ammo
@onready var _timer_bar: ColorRect = $Root/TimerBg/TimerFill
@onready var _log: Label = $Root/Log

var _lines: Array[String] = []

func _ready() -> void:
	Events.cycle_changed.connect(_on_cycle_changed)
	Events.ammo_changed.connect(_on_ammo_changed)
	Events.timer_changed.connect(_on_timer_changed)
	Events.log_line.connect(_on_log_line)

func _on_cycle_changed(cycle: int, resets_left: int) -> void:
	_cycle.text = "CYCLE %02d   RESETS %02d" % [cycle, resets_left]

func _on_ammo_changed(ammo: int) -> void:
	_ammo.text = "AMMO %02d" % ammo

func _on_timer_changed(ratio: float) -> void:
	_timer_bar.size.x = clampf(ratio, 0.0, 1.0) * TIMER_FULL_WIDTH

func _on_log_line(text: String) -> void:
	_lines.append("> " + text)
	while _lines.size() > MAX_LINES:
		_lines.pop_front()
	_log.text = "\n".join(_lines)
