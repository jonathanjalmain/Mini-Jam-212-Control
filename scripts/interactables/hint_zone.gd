extends Area2D

@export_multiline var text := ""

var _fired := false

func _ready() -> void:
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node) -> void:
	if _fired:
		return
	if body.is_in_group("player"):
		_fired = true
		Events.log_line.emit(text)
