extends Node

# Set true to make every chamber selectable (for testing / judges).
const UNLOCK_ALL := false

const SAVE_PATH := "user://progress.cfg"

var completed := {}

func _ready() -> void:
	var c := ConfigFile.new()
	if c.load(SAVE_PATH) == OK:
		for p in c.get_value("progress", "done", []):
			completed[p] = true

func mark(path: String) -> void:
	if completed.has(path):
		return
	completed[path] = true
	var c := ConfigFile.new()
	c.set_value("progress", "done", completed.keys())
	c.save(SAVE_PATH)

func is_completed(path: String) -> bool:
	return completed.has(path)
