extends Node

var room_code : String

func _ready():
	if(ServerConnection._client == null):
		ServerConnection.create_client()
		yield(ServerConnection.create_session(), "completed")
		yield(ServerConnection.connect_server_async(), "completed")
	$CanvasLayer/BlockingPanel.visible = false

func _on_CreateNewMatchButton_pressed():
	room_code = yield(ServerConnection.create_match_async(), "completed")
	if !room_code.empty() && !room_code.match("Error*"):
		get_tree().change_scene("res://MatchRoom/MatchRoom.tscn")
	else:
		$CanvasLayer/CreateMatch/ErrorCreating.text = room_code

func _on_JoinButton_pressed():
	var labelFromEditText = $CanvasLayer/JoinMatch/RoomCodeEdit.text
	room_code = yield(ServerConnection.connect_match_async(labelFromEditText), "completed")

	if !room_code.empty() && !room_code.match("Error*"):
		get_tree().change_scene("res://MatchRoom/MatchRoom.tscn")
	else:
		$CanvasLayer/JoinMatch/ErrorJoining.text = room_code
