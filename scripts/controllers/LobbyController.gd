extends CanvasLayer

export var lobby_component: PackedScene

onready var _actions_container: Node = find_node("Actions")
onready var _lobbies_container: Node = find_node("Lobbies")
onready var _lobby_timer: Timer = $"./Get Lobbies Timer"
onready var _lobby_updater: HTTPRequest = $"./Lobby Updater"
onready var _network_controller: Node = $"../".find_node("NetworkController")

onready var _direct_join_button: Button = _actions_container.get_node("./Direct Join")
onready var _join_button: Button = _actions_container.get_node("./Join")
onready var _ip_address_input: LineEdit = _actions_container.get_node("./IPAddress")
onready var _main_menu_button: Button = _actions_container.get_node("./Main Menu")

var _lobby_data: Array = []
var _selected_lobby


func _on_direct_join_button_pressed():
	_network_controller.create_client(_ip_address_input.text, 31400)
	store.dispatch(actions.client_set_state(ClientConstants.GAME))
	store.emit_signal("game_initializing")


func _on_join_button_pressed():
	var _local_address = _network_controller.get_localhost_game_address(_selected_lobby.name)
	var _connecting_address = _local_address if _local_address != "" else _selected_lobby.host

	_network_controller.create_client(_selected_lobby.host, 31400)
	store.dispatch(actions.client_set_state(ClientConstants.GAME))
	store.emit_signal("game_initializing")


func _on_lobby_component_button_pressed(lobby):
	for _lobby_component in _lobbies_container.get_children():
		var _lobby_component_button = _lobby_component.find_node("Button")

		if !(lobby.name in _lobby_component.find_node("Lobby Info").text):
			_lobby_component_button.pressed = false
		else:
			if _lobby_component_button.pressed:
				_selected_lobby = lobby
			else:
				_selected_lobby = null

	_join_button.disabled = _selected_lobby == null


func _on_lobby_data_updated():
	var _selected_lobby_exists: bool = false

	GDUtil.queue_free_children(_lobbies_container)

	if _lobby_data.size() == 0:
		var _loading_label = Label.new()

		_loading_label.text = "Loading Lobbies..."
		_lobbies_container.add_child(_loading_label)

	for _lobby in _lobby_data:
		var _new_lobby_component = lobby_component.instance()

		_new_lobby_component.find_node("Lobby Info").text = "{host} - {name}".format(_lobby)
		_new_lobby_component.find_node("Button").connect("pressed", self, "_on_lobby_component_button_pressed", [_lobby])

		if _selected_lobby && _selected_lobby.name == _lobby.name:
			_new_lobby_component.find_node("Button").pressed = true
			_selected_lobby_exists = true

		_lobbies_container.add_child(_new_lobby_component)

	if !_selected_lobby_exists:
		_selected_lobby = null

	_join_button.disabled = _selected_lobby == null


func _on_lobby_timer_timeout():
	_lobby_updater.request(ClientConstants.LOBBY_SERVER_ROOT)


func _on_lobby_updater_request_completed(result, response_code, headers, body):
	if result == 0 && response_code == 200:
		var _json_response = JSON.parse(body.get_string_from_utf8()).result

		_lobby_data = _json_response if _json_response else []
	else:
		_lobby_data = []

	_on_lobby_data_updated()


func _on_main_menu_button_pressed():
	store.dispatch(actions.client_set_state(ClientConstants.MENU))


func _on_store_updated(name, state):
	match name:
		"client":
			if state["state"] == ClientConstants.LOBBY:
				offset.y = 0
				_on_lobby_timer_timeout()
				_lobby_timer.start()
			else:
				offset.y = 2000
				_lobby_timer.stop()


func _ready():
	_direct_join_button.connect("pressed", self, "_on_direct_join_button_pressed")
	_join_button.connect("pressed", self, "_on_join_button_pressed")
	_lobby_timer.connect("timeout", self, "_on_lobby_timer_timeout")
	_lobby_updater.connect("request_completed", self, "_on_lobby_updater_request_completed")
	_main_menu_button.connect("pressed", self, "_on_main_menu_button_pressed")
	store.subscribe(self, "_on_store_updated")
