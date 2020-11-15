extends KinematicBody2D

var last_position := Vector2.ZERO
var next_position := Vector2.ZERO

onready var tween = $Tween

func update_state():
	tween.interpolate_property(self, "global_position", global_position, next_position, 0.1)
	tween.start()
