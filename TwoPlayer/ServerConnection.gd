extends Node

signal presences_changed
signal state_updated

const KEY = "battle_pong_581"

var _client : NakamaClient
var _session : NakamaSession
var _socket : NakamaSocket
var _match_id : String
var presences = {}

var deviceid : String
var room_code : String

var renew_token_timer

func _ready():
	get_tree().set_auto_accept_quit(false)

func create_client():
	var scheme = "http"
	var host = "battle-pong.hopto.org"
	var port = 7350
	_client = Nakama.create_client(KEY, host, port, scheme)

func create_session():
	deviceid = OS.get_unique_id()
	_session = yield(_client.authenticate_device_async(deviceid), "completed")

	if _session.is_exception():
		print("An error ocurred: %s" % _session)
	print("Successfully authenticated: %s" % _session)

func connect_server_async():
	_socket = Nakama.create_socket_from(_client)
	var result: NakamaAsyncResult = yield(_socket.connect_async(_session), "completed")
	if not result.is_exception():
		_socket.connect("closed", self, "on_NakamaSocket_closed")
		_socket.connect("received_match_presence", self, "_on_NakamaSocket_received_match_presence")
		_socket.connect("received_match_state", self, "_on_NakamaSocket_received_match_state")
		return OK
	return ERR_CANT_CONNECT

func create_match_async():
	if _match_id.empty():
		var match_created: NakamaAPI.ApiRpc = yield(_client.rpc_async(_session, "create_match_and_get_label", ""), "completed")
		if not match_created.is_exception():
			_match_id = match_created.payload

		var match_join_result: NakamaRTAPI.Match = yield(_socket.join_match_async(_match_id), "completed")

		if match_join_result.is_exception():
			var exception: NakamaException = match_join_result.get_exception()
			printerr("Error joining the match: %s - %s" % [exception.status_code, exception.message])
			return {}

		for presence in match_join_result.presences:
			presences[presence.user_id] = presence
			
		room_code = match_join_result.label
		return room_code
	else:
		printerr("Already in a match")
		
func connect_match_async(label: String):
	if _match_id.empty():
		var payload = { "label": label }
		var match_found: NakamaAPI.ApiRpc = yield(_client.rpc_async(_session, "get_match_by_label", JSON.print(payload)), "completed")
		if not match_found.is_exception():
			_match_id = match_found.payload
		var match_join_result: NakamaRTAPI.Match = yield(_socket.join_match_async(_match_id), "completed")

		if match_join_result.is_exception():
			_match_id = ""
			var exception: NakamaException = match_join_result.get_exception()
			printerr("Error joining the match: %s - %s" % [exception.status_code, exception.message])
			return "Error - " + exception.message

		for presence in match_join_result.presences:
			presences[presence.user_id] = presence
			
		room_code = match_join_result.label
		return room_code
	else:
		printerr("Already in a match")

func leave_match():
	yield(_socket.leave_match_async(_match_id), "completed")
	_match_id = ""
	presences = {}
	
	emit_signal("presences_changed")

func get_match_list():
	return yield(_client.rpc_async(_session, "get_match_list", ""), "completed")

func _on_NakamaSocket_received_match_presence(new_presences: NakamaRTAPI.MatchPresenceEvent) -> void:
	for leave in new_presences.leaves:
		#warning-ignore: return_value_discarded
		presences.erase(leave.user_id)

	for join in new_presences.joins:
		presences[join.user_id] = join

	emit_signal("presences_changed")
	
func _on_NakamaSocket_received_match_state(match_state: NakamaRTAPI.MatchData):
	var code := match_state.op_code
	var raw := match_state.data
	var decoded = JSON.parse(raw).result
	
	print(decoded["playerReady"])
	
	emit_signal("state_updated")

func on_NakamaSocket_closed():
	_socket = null
	
func _notification(what):
	if what == MainLoop.NOTIFICATION_WM_QUIT_REQUEST && !_match_id.empty():
		yield(leave_match(), "completed")
	if what == MainLoop.NOTIFICATION_WM_QUIT_REQUEST:
		get_tree().quit()


func _on_RenewTokenTimer_timeout():
	print("NEW SESSION?")	
	if(_session != null):
		yield(create_session(), "completed")
		print("YES!!!! NEW SESSION")
	else:
		print("NOOOOOOOO")
