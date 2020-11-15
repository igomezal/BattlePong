extends KinematicBody2D

var next_position := Vector2.ZERO

onready var tween = $Tween

func update_state():
	tween.interpolate_property(self, "global_position", global_position, next_position, 0.1, Tween.TRANS_LINEAR, Tween.EASE_OUT_IN)
	tween.start()
