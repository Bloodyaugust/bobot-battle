extends Node

export var dummy_ai_scene: PackedScene
export var player_scene: PackedScene

onready var _map: Node = $"../Map"

var _player_slots: int


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
				if state.keys().size() == _player_slots:
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
	var _players_node = Node.new()

	_players_node.name = "Players"

	_player_slots = _map.spawn_points.size()

	get_parent().add_child(_players_node)

	var _player_id: int = 0
	for _spawn_point in _map.spawn_points:
		var _player = player_scene.instance()

		_player.id = _player_id
		_player.is_local_player = _player_id == 0
		_player.position = _spawn_point.position

		if _player_id != 0:
			_player.add_child(dummy_ai_scene.instance())

		_players_node.add_child(_player)

		store.dispatch(actions.player_add_player(_player_id))
		_player_id += 1

	store.subscribe(self, "_on_store_changed")
	store.emit_signal("game_initialized")
