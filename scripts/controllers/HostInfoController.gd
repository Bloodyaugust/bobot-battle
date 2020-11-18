extends CanvasLayer

onready var _game_name_label: Label = find_node("Game Name")
onready var _lobby_creator: HTTPRequest = find_node("Lobby Creator")
onready var _lobby_keepalive: HTTPRequest = find_node("Lobby Keepalive")
onready var _lobby_keepalive_timer: Timer = find_node("Lobby Keepalive Timer")
onready var _network_controller: Node = get_tree().get_root().find_node("NetworkController", true, false)
onready var _players_label: Label = find_node("Players")

var _game_lobby = {}


func _on_lobby_creator_request_completed(result, response_code, headers, body):
	if result == 0 && response_code == 200:
		var _json_response = JSON.parse(body.get_string_from_utf8()).result

		_game_lobby = _json_response if _json_response else {}
		_lobby_keepalive_timer.start()
	else:
		_game_lobby = {}

	_on_lobby_data_updated()


func _on_lobby_data_updated():
	_game_name_label.text = "Game Name: {name}".format(_game_lobby)


func _on_lobby_keepalive_request_completed(result, response_code, headers, body):
	if result == 0 && response_code == 200:
		print("Lobby kept alive")
	else:
		print("Issue with keeping lobby alive")


func _on_lobby_keepalive_timer_timeout():
	_lobby_keepalive.request(ClientConstants.LOBBY_SERVER_ROOT + "lobby/{name}/keepalive".format(_game_lobby))


func _on_network_peer_connected(id: int):
	_players_label.text = "Players: {players}/{max_players}".format({"players": get_tree().get_network_connected_peers().size(), "max_players": _network_controller.max_clients})


func _on_network_peer_disconnected(id: int):
	_players_label.text = "Players: {players}/{max_players}".format({"players": get_tree().get_network_connected_peers().size(), "max_players": _network_controller.max_clients})


func _on_server_created():
	_lobby_creator.request(ClientConstants.LOBBY_SERVER_ROOT + "new")


func _on_store_updated(name, state):
	match name:
		"client":
			if state["state"] == ClientConstants.GAME && get_tree().is_network_server():
				offset.y = 0

				_game_name_label.text = "Game Name: {name}".format(_game_lobby)
				_players_label.text = "Players: {players}/{max_players}".format({"players": get_tree().get_network_connected_peers().size(), "max_players": _network_controller.max_clients})
			else:
				offset.y = 2000


func _ready():
	_lobby_creator.connect("request_completed", self, "_on_lobby_creator_request_completed")
	_lobby_keepalive.connect("request_completed", self, "_on_lobby_keepalive_request_completed")
	_lobby_keepalive_timer.connect("timeout", self, "_on_lobby_keepalive_timer_timeout")
	_network_controller.connect("server_created", self, "_on_server_created")
	get_tree().connect("network_peer_connected", self, "_on_network_peer_connected")
	get_tree().connect("network_peer_disconnected", self, "_on_network_peer_disconnected")
	store.subscribe(self, "_on_store_updated")
