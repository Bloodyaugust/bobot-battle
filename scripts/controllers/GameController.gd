extends Node

export var player_slots: int

onready var _map: Node = $"../Map"


func _is_game_over() -> bool:
	var _dead_players: int = 0
	var _players: Array = get_tree().get_nodes_in_group("player")

	for _player in _players:
		if _player.get_state()["health"] <= 0:
			_dead_players += 1

	return _dead_players >= _players.size() - 1


func _resolve_player_actions():
	var _players: Array = get_tree().get_nodes_in_group("player")

	while _unresolved_player_actions():
		for _player in _players:
			yield(get_tree().create_timer(0.15), "timeout")
			_player.process_next_action()
			_map.resolve_hazard_actions(_player)

			if _is_game_over():
				store.dispatch(actions.game_set_state(GameStates.OVER))
				return

	for _player in _players:
		store.dispatch(actions.player_set_ready(false, _player.id))

	store.dispatch(actions.game_set_state(GameStates.CHOOSING))


func _unresolved_player_actions() -> bool:
	var _player_states = store.state()["player"]

	for _player_key in _player_states.keys():
		if _player_states[_player_key]["action_queue"].size() != 0:
			return true

	return false


func _on_store_changed(name, state):
	match name:
		"player":
			if store.state()["game"]["state"] == GameStates.WAITING:
				if state.keys().size() == player_slots:
					store.dispatch(actions.game_set_state(GameStates.CHOOSING))
				else:
					return

			for _player_key in state.keys():
				if ! state[_player_key]["ready"]:
					return

			if store.state()["game"]["state"] != GameStates.RESOLVING:
				store.dispatch(actions.game_set_state(GameStates.RESOLVING))
				_resolve_player_actions()

		"game":
			if state["state"] == GameStates.OVER:
				var _players: Array = get_tree().get_nodes_in_group("player")

				for _player in _players:
					_player.queue_free()


func _ready():
	store.subscribe(self, "_on_store_changed")
