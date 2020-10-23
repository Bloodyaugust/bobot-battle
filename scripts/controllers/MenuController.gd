extends CanvasLayer

onready var _play_button = $"./MarginContainer/CenterContainer/VBoxContainer/Play"


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
	_play_button.connect("pressed", self, "_on_play_button_pressed")
	store.subscribe(self, "_on_store_updated")
