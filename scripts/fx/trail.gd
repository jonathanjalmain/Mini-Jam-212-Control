extends Line2D

const MAX_POINTS := 14
const TELEPORT_DIST := 48.0

var _target: Node2D

func _ready() -> void:
	top_level = true
	_target = get_parent()

func _physics_process(_delta: float) -> void:
	if _target == null or not is_instance_valid(_target):
		return
	var p := _target.global_position
	var n := get_point_count()
	if n > 0 and p.distance_to(get_point_position(n - 1)) > TELEPORT_DIST:
		clear_points()
	add_point(p)
	while get_point_count() > MAX_POINTS:
		remove_point(0)
