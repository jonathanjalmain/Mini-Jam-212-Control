extends Area2D

@export_multiline var text := ""
@export var as_subtitle := false

var _fired := false

func _ready() -> void:
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node) -> void:
	if _fired:
		return
	if body.is_in_group("player"):
		_fired = true
		if as_subtitle:
			Events.subtitle.emit(text, "")
		else:
			Events.log_line.emit(text)
