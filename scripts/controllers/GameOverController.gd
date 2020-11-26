extends CanvasLayer

onready var _game_root: Node = $"../Game"
onready var _menu_button: Button = find_node("Menu")


func _on_menu_button_pressed():
	store.dispatch(actions.client_set_state(ClientConstants.MENU))
	GDUtil.queue_free_children(_game_root)
	store.dispatch(actions.game_set_state(GameStates.WAITING))


func _on_store_updated(name, state):
	match name:
		"game":
			if state["state"] == GameStates.OVER:
				offset.y = 0
		"client":
			offset.y = 2000


func _ready():
	_menu_button.connect("pressed", self, "_on_menu_button_pressed")
	store.subscribe(self, "_on_store_updated")
