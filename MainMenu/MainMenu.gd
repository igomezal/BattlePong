extends Node



func _on_SinglePlayer_pressed():
	get_tree().change_scene("res://Level/Level.tscn")
	



func _on_TwoPlayers_pressed():
	get_tree().change_scene("res://TwoPlayer/TwoPlayer.tscn")


func _on_Exit_pressed():
	get_tree().quit()
