extends CanvasLayer

onready var _host_button: Button = $"./MarginContainer/PanelContainer/CenterContainer/VBoxContainer/Host"
onready var _join_button: Button = $"./MarginContainer/PanelContainer/CenterContainer/VBoxContainer/Join"
onready var _play_button: Button = $"./MarginContainer/PanelContainer/CenterContainer/VBoxContainer/Play"
onready var _settings_button: Button = $"./MarginContainer/PanelContainer/CenterContainer/VBoxContainer/Settings"

onready var _network_controller: Node = $"../".find_node("NetworkController")


func _on_host_button_pressed():
	_network_controller.create_server(31400)
	store.dispatch(actions.client_set_state(ClientConstants.GAME))
	store.emit_signal("game_initializing")


func _on_join_button_pressed():
	store.dispatch(actions.client_set_state(ClientConstants.LOBBY))


func _on_play_button_pressed():
	store.dispatch(actions.client_set_state(ClientConstants.GAME))
	store.emit_signal("game_initializing")


func _on_settings_button_pressed():
	store.dispatch(actions.client_set_state(ClientConstants.SETTINGS))


func _on_store_updated(name, state):
	match name:
		"client":
			if state["state"] == ClientConstants.MENU:
				offset.y = 0
			else:
				offset.y = 2000


func _ready():
	_host_button.connect("pressed", self, "_on_host_button_pressed")
	_join_button.connect("pressed", self, "_on_join_button_pressed")
	_play_button.connect("pressed", self, "_on_play_button_pressed")
	_settings_button.connect("pressed", self, "_on_settings_button_pressed")
	store.subscribe(self, "_on_store_updated")
