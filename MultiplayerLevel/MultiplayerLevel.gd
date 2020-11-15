extends Node

var playerScore = 0
var opponentScore = 0

func _ready():
	$CountdownLabel.visible = true
	$CountdownTimer.start()

func _process(delta):
	$PlayerScore.text = str(playerScore)
	$OpponentScore.text = str(opponentScore)
	$CountdownLabel.text = str(int($CountdownTimer.time_left) + 1)
	
func _on_PlayerGoal_body_entered(body):
	opponentScore += 1
	scored()

func _on_OpponentGoal_body_entered(body):
	playerScore += 1
	scored()
	
func scored():
	$Ball.position = Vector2(640, 360)
	get_tree().call_group("BallGroup", "stop_ball")
	$CountdownTimer.start()
	$CountdownLabel.visible = true
	$ScoreSound.play()

func _on_CountdownTimer_timeout():
	get_tree().call_group("BallGroup", "start_ball")
	$CountdownLabel.visible = false
