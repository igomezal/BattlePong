extends Node

func _ready():
	$CanvasLayer/MatchPanel/RoomCodeText.text = ServerConnection.room_code
