extends Area2D

@export_file("*.tscn") var next_scene := "res://scenes/main/Main.tscn"

var _done := false

func _ready() -> void:
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node) -> void:
	if _done:
		return
	if body.is_in_group("player"):
		_done = true
		Events.subtitle.emit("Calibration complete. Proceeding to Chamber 01.", "exit")
		get_tree().create_timer(1.6).timeout.connect(_go)

func _go() -> void:
	get_tree().change_scene_to_file(next_scene)
