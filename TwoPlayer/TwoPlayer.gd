extends Node

var room_code : String

func _ready():
	ServerConnection.create_client()
	yield(ServerConnection.create_session(), "completed")
	yield(ServerConnection.connect_server_async(), "completed")


func _on_CreateNewMatchButton_pressed():
	room_code = yield(ServerConnection.create_match_async(), "completed")
	if !room_code.empty():
		get_tree().change_scene("res://MatchRoom/MatchRoom.tscn")


func _on_JoinButton_pressed():
	var labelFromEditText = $CanvasLayer/JoinMatch/RoomCodeEdit.text
	room_code = yield(ServerConnection.connect_match_async(labelFromEditText), "completed")
	if !room_code.empty():
		get_tree().change_scene("res://MatchRoom/MatchRoom.tscn")
	
