extends CanvasLayer

onready var _actions_container: Node = find_node("Actions")
onready var _lobbies_container: Node = find_node("Lobbies")
onready var _network_controller: Node = $"../".find_node("NetworkController")

onready var _direct_join_button: Button = _actions_container.get_node("./Direct Join")
onready var _join_button: Button = _actions_container.get_node("./Join")
onready var _ip_address_input: LineEdit = _actions_container.get_node("./IPAddress")
onready var _main_menu_button: Button = _actions_container.get_node("./Main Menu")


func _on_direct_join_button_pressed():
	_network_controller.create_client(_ip_address_input.text, 31400)
	store.dispatch(actions.client_set_state(ClientConstants.GAME))
	store.emit_signal("game_initializing")


func _on_join_button_pressed():
	# _network_controller.create_client(_ip_address_input.text, 31400)
	# TODO: Get selected lobby IP
	store.dispatch(actions.client_set_state(ClientConstants.GAME))
	store.emit_signal("game_initializing")


func _on_main_menu_button_pressed():
	store.dispatch(actions.client_set_state(ClientConstants.MENU))


func _on_store_updated(name, state):
	match name:
		"client":
			if state["state"] == ClientConstants.LOBBY:
				offset.y = 0
			else:
				offset.y = 2000


func _ready():
	_direct_join_button.connect("pressed", self, "_on_direct_join_button_pressed")
	_join_button.connect("pressed", self, "_on_join_button_pressed")
	_main_menu_button.connect("pressed", self, "_on_main_menu_button_pressed")
	store.subscribe(self, "_on_store_updated")
