extends Node

onready var playerUI = [
	{
		"playerIcon": $CanvasLayer/MatchPanel/PlayersPanel/Player1,
		"playerText": $CanvasLayer/MatchPanel/PlayersPanel/Player1Name,
		"playerReady": $CanvasLayer/MatchPanel/PlayersPanel/Player1Ready
	},
	{
		"playerIcon": $CanvasLayer/MatchPanel/PlayersPanel/Player2,
		"playerText": $CanvasLayer/MatchPanel/PlayersPanel/Player2Name,
		"playerReady": $CanvasLayer/MatchPanel/PlayersPanel/Player2Ready
	}
]

var ready_state = ServerConnection.player_status.NOT_READY

func _ready():
	ServerConnection.connect("presences_changed", self, "_on_MatchRoom_presences_changed")
	ServerConnection.connect("state_updated", self, "_on_MatchRoom_state_updated")
	ServerConnection.connect("start_match", self, "_on_MatchRoom_start_match")
	$CanvasLayer/MatchPanel/RoomCodeText.text = ServerConnection.room_code
	_on_MatchRoom_presences_changed()


func _on_MatchRoom_presences_changed():
	for ui in playerUI:
		ui.playerIcon.visible = false
		ui.playerText.visible = false
		ui.playerReady.visible = false
		ui.playerText.text = ""
		ui.playerReady.pressed = false
		
	var presences = ServerConnection.presences
	var index = 0
	for presence in presences:
		playerUI[index].playerIcon.visible = true
		playerUI[index].playerText.visible = true
		playerUI[index].playerReady.visible = true
		playerUI[index].playerText.text = presences[presence].username
		index += 1

func _on_MatchRoom_state_updated(player_status):
	for ui in playerUI:
		ui.playerIcon.visible = false
		ui.playerText.visible = false
		ui.playerReady.visible = false
		ui.playerText.text = ""
		ui.playerReady.pressed = false
		
	var presences = ServerConnection.presences
	var index = 0
	var all_ready = true
	for presence in presences:
		playerUI[index].playerIcon.visible = true
		playerUI[index].playerText.visible = true
		playerUI[index].playerReady.visible = true
		playerUI[index].playerReady.pressed = player_status[presence] == ServerConnection.player_status.READY
		playerUI[index].playerText.text = presences[presence].username
		
		index += 1
		
	ready_state = player_status[ServerConnection._session.user_id]
	if ready_state == ServerConnection.player_status.NOT_READY:
		$CanvasLayer/MatchPanel/Ready.text = "READY"
	else:
		$CanvasLayer/MatchPanel/Ready.text = "NOT READY"

func _on_Leave_pressed():
	yield(ServerConnection.leave_match(), "completed")
	get_tree().change_scene("res://TwoPlayer/TwoPlayer.tscn")


func _on_Ready_pressed():
	if ServerConnection.presences.size() == 2:
		if ready_state == ServerConnection.player_status.NOT_READY:
			ready_state = ServerConnection.player_status.READY
			$CanvasLayer/MatchPanel/Ready.text = "NOT READY"
		else:
			ready_state = ServerConnection.player_status.NOT_READY
			$CanvasLayer/MatchPanel/Ready.text = "READY"
		
		ServerConnection.send_status_update(ready_state)

func _on_MatchRoom_start_match():
	get_tree().change_scene("res://MultiplayerLevel/MultiplayerLevel.tscn")
