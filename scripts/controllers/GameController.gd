extends Node

export var dummy_ai_scene: PackedScene
export var player_scene: PackedScene
export var player_name_scene: PackedScene

export remotesync var action_order: String = "1"

onready var _map: Node = $"../Map"

master var _completed_simulations: Array
master var _completed_simulation_strings: Array
var _players_node: Node
var _player_names_node: Node
var _player_slots: int

remote func simulation_completed(id: int, round_string: String):
	var _players = _players_node.get_children()

	_completed_simulations.append(id)
	_completed_simulation_strings.append(round_string)

	for _round_string in _completed_simulation_strings:
		assert(_round_string == _completed_simulation_strings[0], _completed_simulation_strings)

	if _completed_simulations.size() == _players.size():
		if _is_game_over():
			store.remotesync_dispatch(actions.game_set_state(GameStates.OVER))
		else:
			store.remotesync_dispatch(actions.game_set_state(GameStates.CHOOSING))
		_completed_simulations.clear()
		_completed_simulation_strings.clear()
		

remotesync func spawn_player(id: int):
	var _player = player_scene.instance()
	var _player_name = player_name_scene.instance()
	var _players = get_tree().get_nodes_in_group("player")

	_player.id = id
	_player.is_local_player = get_tree().get_network_unique_id() == id
	_player.position = _map.spawn_points[_players.size()].position
	_player.name = str(id)
	_player.player_name_node = _player_name

	_player_names_node.add_child(_player_name)
	_players_node.add_child(_player)

	if _player.is_local_player:
		store.emit_signal("local_player_spawned")

	if get_tree().is_network_server():
		_player.set_network_master(id)


func _is_game_over() -> bool:
	var _dead_players: int = 0
	var _players: Array = get_tree().get_nodes_in_group("player")

	for _player in _players:
		if _player.health <= 0:
			_dead_players += 1

	return _dead_players >= _players.size() - 1


func _resolve_player_actions():
	var _current_action: int = 0
	var _players: Array = get_tree().get_nodes_in_group("player")
	var _resolved_actions: String = ""

	while _current_action < PlayerActions.MAX_ACTIONS_QUEUED:
		for _player_id in action_order.split(","):
			yield(get_tree().create_timer(0.15), "timeout")
			var _player = _players_node.get_node(str(_player_id))
			_resolved_actions += "Player {id}, action {current_action}, ".format({"current_action": _current_action, "id": _player_id})
			_resolved_actions += _player.process_action(_current_action)
			_resolved_actions += ", "
			_resolved_actions += _map.resolve_hazard_actions(_player)
			_resolved_actions += "; "

		_current_action += 1

	# print(_resolved_actions)
	if get_tree().is_network_server():
		simulation_completed(1, _resolved_actions)
	else:
		rpc_id(1, "simulation_completed", get_tree().get_network_unique_id(), _resolved_actions)



func _on_network_peer_connected(id: int):
	var _players = get_tree().get_nodes_in_group("player")

	for _player in _players:
		rpc_id(id, "spawn_player", _player.id)

	store.remote_dispatch_id(actions.game_set_state(store.state()["game"]["state"]), id)

	rpc("spawn_player", id)

	call_deferred("rset", "action_order", action_order + "," + str(id))


func _on_store_changed(name, state):
	match name:
		"game":
			if state["state"] == GameStates.RESOLVING:
				_resolve_player_actions()


func _process(_delta):
	if get_tree().is_network_server():
		var _players = get_tree().get_nodes_in_group("player")

		if store.state()["game"]["state"] == GameStates.WAITING:
			store.remotesync_dispatch(actions.game_set_state(GameStates.CHOOSING))

		for _player in _players:
			if ! _player.ready:
				return

		if store.state()["game"]["state"] != GameStates.RESOLVING:
			store.remotesync_dispatch(actions.game_set_state(GameStates.RESOLVING))


func _ready():
	_players_node = Node.new()
	_player_names_node = Node.new()

	_players_node.name = "Players"
	_player_names_node.name = "Player Names"

	_player_slots = _map.spawn_points.size()

	get_parent().add_child(_player_names_node)
	get_parent().add_child(_players_node)

	if get_tree().is_network_server():
		spawn_player(get_tree().get_network_unique_id())
		get_tree().connect("network_peer_connected", self, "_on_network_peer_connected")

	store.subscribe(self, "_on_store_changed")
	store.emit_signal("game_initialized")
