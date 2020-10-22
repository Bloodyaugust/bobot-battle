extends Node2D

onready var id: int = get_parent().id


func _on_store_updated(name, state):
	match name:
		"player":
			if (
				state.has(id)
				&& ! state[id]["ready"]
				&& store.state()["game"]["state"] == GameStates.WAITING
			):
				store.dispatch(actions.player_set_ready(true, id))
		"game":
			if state["state"] == GameStates.CHOOSING:
				store.dispatch(actions.player_set_ready(true, id))


func _ready():
	store.subscribe(self, "_on_store_updated")
