extends Node

export var game_controller: PackedScene
export var map: PackedScene

onready var _game: Node = $"./Game"


func _on_game_initalizing():
	store.dispatch(actions.client_set_map("test-small"))
	_game.add_child(map.instance())
	_game.add_child(game_controller.instance())


func _ready() -> void:
	store.create(
		[
			{"name": "client", "instance": reducers},
			{"name": "game", "instance": reducers},
			{"name": "player", "instance": reducers}
		],
		[{"name": "_on_store_changed", "instance": self}]
	)
	store.dispatch(actions.game_set_start_time(OS.get_unix_time()))
	store.dispatch(actions.client_set_state(ClientConstants.MENU))

	store.connect("game_initializing", self, "_on_game_initalizing")


func _on_store_changed(name, state) -> void:
	print(name, ": ", state)
