extends CanvasLayer

onready var _game_name_label: Label = find_node("Game Name")
onready var _network_controller: Node = get_tree().get_root().find_node("NetworkController", true, false)
onready var _players_label: Label = find_node("Players")

var _game_lobby


func _on_network_peer_connected(id: int):
	_players_label.text = "Players: {players}/{max_players}".format({"players": get_tree().get_network_connected_peers().size(), "max_players": _network_controller.max_clients})


func _on_network_peer_disconnected(id: int):
	_players_label.text = "Players: {players}/{max_players}".format({"players": get_tree().get_network_connected_peers().size(), "max_players": _network_controller.max_clients})


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
	get_tree().connect("network_peer_connected", self, "_on_network_peer_connected")
	get_tree().connect("network_peer_disconnected", self, "_on_network_peer_disconnected")
	store.subscribe(self, "_on_store_updated")
