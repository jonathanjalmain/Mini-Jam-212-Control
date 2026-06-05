extends Area2D

var dir := 1
var speed := 360.0
var shooter: Node = null

func setup(d: int, s: float, sh: Node) -> void:
	dir = d
	speed = s
	shooter = sh

func _ready() -> void:
	add_to_group("bullets")
	body_entered.connect(_on_body_entered)

func _physics_process(delta: float) -> void:
	position.x += dir * speed * delta

func _on_body_entered(body: Node) -> void:
	if body == shooter:
		return
	if body.is_in_group("player"):
		if body.has_method("die"):
			body.die()
		queue_free()
	elif body.is_in_group("clones"):
		if not body.frozen:
			body.freeze()
		queue_free()
	else:
		queue_free()
