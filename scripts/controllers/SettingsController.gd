extends CanvasLayer

onready var _settings_root: Node = $"./MarginContainer"

onready var _main_menu_button: Button = _settings_root.find_node("Main Menu")
onready var _player_name_input: LineEdit = _settings_root.find_node("Player Name")
onready var _save_button: Button = _settings_root.find_node("Save")

var _player_name: String


func get_player_settings() -> Dictionary:
	return {
		"name": _player_name
	}


func _load_settings():
	var _settings_file = File.new()
	var _settings = {
		"name": "Player"
	}

	if !_settings_file.file_exists(ClientConstants.SETTINGS_FILE_PATH):
		_settings_file.open(ClientConstants.SETTINGS_FILE_PATH, File.WRITE)
		_settings_file.store_string(JSON.print(_settings))
	else:
		_settings_file.open(ClientConstants.SETTINGS_FILE_PATH, File.READ)
		_settings = JSON.parse(_settings_file.get_as_text()).result

	_settings_file.close()

	_player_name = _settings.name


func _on_main_menu_button_pressed():
	store.dispatch(actions.client_set_state(ClientConstants.MENU))


func _on_save_button_pressed():
	var _settings_file = File.new()

	_player_name = _player_name_input.text

	var _new_settings = {
		"name": _player_name
	}

	_settings_file.open(ClientConstants.SETTINGS_FILE_PATH, File.WRITE)
	_settings_file.store_string(JSON.print(_new_settings))
	_settings_file.close()


func _on_show():
	_player_name_input.text = _player_name


func _on_store_updated(name, state):
	match name:
		"client":
			if state["state"] == ClientConstants.SETTINGS:
				_on_show()
				offset.y = 0
			else:
				offset.y = 2000


func _ready():
	_main_menu_button.connect("pressed", self, "_on_main_menu_button_pressed")
	_save_button.connect("pressed", self, "_on_save_button_pressed")
	store.subscribe(self, "_on_store_updated")

	_load_settings()
