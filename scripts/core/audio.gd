extends Node

const SAVE := "user://audio.cfg"
const BUSES := ["Ambience", "SFX", "Voice"]
const DEFAULTS := {"Master": 0.3, "Ambience": 0.1, "SFX": 0.2, "Voice": 0.4}

func _ready() -> void:
	for b in BUSES:
		if AudioServer.get_bus_index(b) == -1:
			var i := AudioServer.bus_count
			AudioServer.add_bus(i)
			AudioServer.set_bus_name(i, b)
			AudioServer.set_bus_send(i, "Master")
	for b in DEFAULTS:
		var i := AudioServer.get_bus_index(b)
		if i >= 0:
			AudioServer.set_bus_volume_db(i, linear_to_db(clampf(DEFAULTS[b], 0.0001, 1.0)))
	_load()

func set_linear(bus: String, v: float) -> void:
	var i := AudioServer.get_bus_index(bus)
	if i >= 0:
		AudioServer.set_bus_volume_db(i, linear_to_db(clampf(v, 0.0001, 1.0)))
	_save()

func get_linear(bus: String) -> float:
	var i := AudioServer.get_bus_index(bus)
	if i < 0:
		return 1.0
	return clampf(db_to_linear(AudioServer.get_bus_volume_db(i)), 0.0, 1.0)

func _save() -> void:
	var cfg := ConfigFile.new()
	cfg.set_value("vol", "Master", get_linear("Master"))
	for b in BUSES:
		cfg.set_value("vol", b, get_linear(b))
	cfg.save(SAVE)

func _load() -> void:
	var cfg := ConfigFile.new()
	if cfg.load(SAVE) != OK:
		return
	for b in (["Master"] + BUSES):
		var i := AudioServer.get_bus_index(b)
		if i >= 0:
			var v: float = cfg.get_value("vol", b, 1.0)
			AudioServer.set_bus_volume_db(i, linear_to_db(clampf(v, 0.0001, 1.0)))
