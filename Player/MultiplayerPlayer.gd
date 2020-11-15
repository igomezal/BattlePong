extends KinematicBody2D

export var speed = 400

func _ready():
	global_position = position

func _physics_process(delta):
	var velocity = Vector2.ZERO
	if Input.is_action_pressed("move_up"):
		velocity.y -= 1
	if Input.is_action_pressed("move_down"):
		velocity.y += 1
	move_and_slide(velocity * speed)


func _on_UpdateTimer_timeout():
	ServerConnection.send_position_update(global_position)
