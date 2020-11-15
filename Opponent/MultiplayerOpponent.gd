extends KinematicBody2D

export var speed = 400

var next_position := Vector2.ZERO

onready var tween = $Tween

func _physics_process(delta):
	position = position.move_toward(next_position, delta * speed)

func update_state():
	tween.interpolate_property(self, "global_position", global_position, next_position, 0.1, Tween.TRANS_LINEAR, Tween.EASE_OUT_IN)
	tween.start()
