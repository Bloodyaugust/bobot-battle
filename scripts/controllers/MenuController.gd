extends CanvasLayer

onready var _host_button: Button = $"./MarginContainer/CenterContainer/VBoxContainer/Host"
onready var _ip_address_input: LineEdit = $"./MarginContainer/CenterContainer/VBoxContainer/IPAddress"
onready var _join_button: Button = $"./MarginContainer/CenterContainer/VBoxContainer/Join"
onready var _play_button: Button = $"./MarginContainer/CenterContainer/VBoxContainer/Play"

onready var _network_controller: Node = $"../".find_node("NetworkController")
onready var _peer_discovery_controller: Node = $"../".find_node("PeerDiscoveryController")


func _on_host_button_pressed():
	_peer_discovery_controller.close()
	_network_controller.create_server(31400)
	store.dispatch(actions.client_set_state(ClientConstants.GAME))
	store.emit_signal("game_initializing")


func _on_join_button_pressed():
	# _network_controller.ip_address = _ip_address_input.text
	_peer_discovery_controller.close()
	_network_controller.create_client(_peer_discovery_controller.get_host_address(), _peer_discovery_controller.get_host_port())
	store.dispatch(actions.client_set_state(ClientConstants.GAME))
	store.emit_signal("game_initializing")


func _on_play_button_pressed():
	store.dispatch(actions.client_set_state(ClientConstants.GAME))
	store.emit_signal("game_initializing")


func _on_store_updated(name, state):
	match name:
		"client":
			if state["state"] == ClientConstants.GAME:
				offset.y = 2000
			else:
				offset.y = 0


func _ready():
	_host_button.connect("pressed", self, "_on_host_button_pressed")
	_join_button.connect("pressed", self, "_on_join_button_pressed")
	_play_button.connect("pressed", self, "_on_play_button_pressed")
	store.subscribe(self, "_on_store_updated")
