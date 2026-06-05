class_name Level
extends Node2D

@export var cycle_duration_ticks := 600
@export var max_resets := 30
@export var bullets_per_map := 2
@export var no_timer := false

@export var cam_left := 0
@export var cam_top := 0
@export var cam_right := 640
@export var cam_bottom := 360

var spawn_pad: Node2D = null
var goal_zone: Node = null

func _ready() -> void:
	if spawn_pad == null:
		spawn_pad = get_node_or_null("SpawnPad")
	if goal_zone == null:
		goal_zone = get_node_or_null("GoalZone")
