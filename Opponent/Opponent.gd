extends KinematicBody2D

export var speed = 400
var ball

func _ready():
	ball = get_parent().find_node("Ball")
	
func _physics_process(delta):
	if(ball.velocity.x > 0):
		move_and_slide(Vector2(0, get_opponent_direction()) * speed)
	
func get_opponent_direction():
	if abs(ball.position.y - position.y) > 25:
		if ball.position.y > position.y: return 1
		else: return -1
	else: return 0
