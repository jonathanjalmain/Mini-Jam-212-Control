class_name InputFrame
extends RefCounted

var left := false
var right := false
var jump := false
var dash := false
var shoot := false
var carrying := false

static func capture() -> InputFrame:
	var f := InputFrame.new()
	f.left = Input.is_action_pressed("move_left")
	f.right = Input.is_action_pressed("move_right")
	f.jump = Input.is_action_pressed("jump")
	f.dash = Input.is_action_pressed("dash")
	f.shoot = Input.is_action_pressed("shoot")
	return f

static func empty() -> InputFrame:
	return InputFrame.new()
