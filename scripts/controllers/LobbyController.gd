extends CanvasLayer

export var lobby_component: PackedScene

onready var _actions_container: Node = find_node("Actions")
onready var _lobbies_container: Node = find_node("Lobbies")
onready var _network_controller: Node = $"../".find_node("NetworkController")

onready var _direct_join_button: Button = _actions_container.get_node("./Direct Join")
onready var _join_button: Button = _actions_container.get_node("./Join")
onready var _ip_address_input: LineEdit = _actions_container.get_node("./IPAddress")
onready var _main_menu_button: Button = _actions_container.get_node("./Main Menu")

var _lobby_data: Array = [{"host": "127.0.0.1", "name": "Test Map Small N00BZ ONLY"}, {"host": "127.0.0.2", "name": "Test Map Small PR0Z ONLY"}, {"host": "127.0.0.3", "name": "Test Map Small ALL WELCOME"}]
var _selected_lobby


func _on_direct_join_button_pressed():
	_network_controller.create_client(_ip_address_input.text, 31400)
	store.dispatch(actions.client_set_state(ClientConstants.GAME))
	store.emit_signal("game_initializing")


func _on_join_button_pressed():
	# _network_controller.create_client(_ip_address_input.text, 31400)
	# TODO: Get selected lobby IP
	store.dispatch(actions.client_set_state(ClientConstants.GAME))
	store.emit_signal("game_initializing")


func _on_lobby_component_button_pressed(lobby):
	for _lobby_component in _lobbies_container.get_children():
		var _lobby_component_button = _lobby_component.find_node("Button")

		if !(lobby.host in _lobby_component.find_node("Lobby Info").text):
			_lobby_component_button.pressed = false
		else:
			if _lobby_component_button.pressed:
				_selected_lobby = lobby
			else:
				_selected_lobby = null

	_join_button.disabled = _selected_lobby == null


func _on_lobby_data_updated():
	GDUtil.queue_free_children(_lobbies_container)

	for _lobby in _lobby_data:
		var _new_lobby_component = lobby_component.instance()

		_new_lobby_component.find_node("Lobby Info").text = "{host} - {name}".format(_lobby)
		_new_lobby_component.find_node("Button").connect("pressed", self, "_on_lobby_component_button_pressed", [_lobby])

		_lobbies_container.add_child(_new_lobby_component)


func _on_main_menu_button_pressed():
	store.dispatch(actions.client_set_state(ClientConstants.MENU))


func _on_store_updated(name, state):
	match name:
		"client":
			if state["state"] == ClientConstants.LOBBY:
				offset.y = 0
				_on_lobby_data_updated()
			else:
				offset.y = 2000


func _ready():
	_direct_join_button.connect("pressed", self, "_on_direct_join_button_pressed")
	_join_button.connect("pressed", self, "_on_join_button_pressed")
	_main_menu_button.connect("pressed", self, "_on_main_menu_button_pressed")
	store.subscribe(self, "_on_store_updated")
