class_name Recorder
extends RefCounted

var frames: Array[InputFrame] = []

func reset() -> void:
	frames.clear()

func record(f: InputFrame) -> void:
	frames.append(f)

func get_recording() -> Array[InputFrame]:
	return frames.duplicate()
