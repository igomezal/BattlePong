extends Node

var playerScore = 0
var opponentScore = 0

var startingX = [25.0, 1255.0]
var player_opponent

func _ready():
	_compute_starting_position()
	$CountdownLabel.visible = true
	$CountdownTimer.start()
	ServerConnection.connect("update_positions", self, "_on_Opponent_position_updated")

func _process(delta):
	$PlayerScore.text = str(playerScore)
	$OpponentScore.text = str(opponentScore)
	$CountdownLabel.text = str(int($CountdownTimer.time_left) + 1)
	
func _compute_starting_position():
	player_opponent = ServerConnection.compute_initial_player_opponent_positions()
	$MultiplayerPlayer.position.x = startingX[player_opponent.player.pos]
	$MultiplayerPlayer.visible = true
	
	$MultiplayerOpponent.next_position = Vector2(startingX[player_opponent.opponent.pos], 360)
	$MultiplayerOpponent.position.x = startingX[player_opponent.opponent.pos]
	$MultiplayerOpponent.visible = true
	
	ServerConnection.send_position_update($MultiplayerPlayer.position)
	
func _on_PlayerGoal_body_entered(body):
	opponentScore += 1
	scored()

func _on_OpponentGoal_body_entered(body):
	playerScore += 1
	scored()
	
func scored():
	$Ball.position = Vector2(640, 360)
	# get_tree().call_group("BallGroup", "stop_ball")
	$CountdownTimer.start()
	$CountdownLabel.visible = true
	$ScoreSound.play()

func _on_CountdownTimer_timeout():
	# get_tree().call_group("BallGroup", "start_ball")
	$CountdownLabel.visible = false

func _on_Opponent_position_updated(positions):
	var update := true
	var next_position: Dictionary = positions[player_opponent.opponent.id]
	$MultiplayerOpponent.next_position = Vector2(startingX[player_opponent.opponent.pos], next_position.y)
	# $MultiplayerOpponent.update_state()

