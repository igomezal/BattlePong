extends Node

onready var playerUI = [
	{ "playerIcon": $CanvasLayer/MatchPanel/PlayersPanel/Player1, "playerText": $CanvasLayer/MatchPanel/PlayersPanel/Player1Name },
	{ "playerIcon": $CanvasLayer/MatchPanel/PlayersPanel/Player2, "playerText": $CanvasLayer/MatchPanel/PlayersPanel/Player2Name }
]

func _ready():
	ServerConnection.connect("presences_changed", self, "_on_MatchRoom_presences_changed")
	$CanvasLayer/MatchPanel/RoomCodeText.text = ServerConnection.room_code
	_on_MatchRoom_presences_changed()


func _on_MatchRoom_presences_changed():
	for ui in playerUI:
		ui.playerIcon.visible = false
		ui.playerText.text = ""
	var presences = ServerConnection.presences
	var index = 0
	for presence in presences:
		playerUI[index].playerIcon.visible = true
		playerUI[index].playerText.text = presences[presence].username
		index += 1

