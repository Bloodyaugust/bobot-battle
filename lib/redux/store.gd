extends Node

var _state = {"client": {}, "game": {"state": GameStates.WAITING, "start_time": 0}, "player": {}}
var _reducers = {}

signal game_initializing
signal game_initialized
signal local_player_spawned
signal map_loaded
signal state_changed(name, state)


func create(reducers, callbacks = null) -> void:
	for reducer in reducers:
		var name = reducer["name"]
		if not _state.has(name):
			_state[name] = {}
		if not _reducers.has(name):
			_reducers[name] = funcref(reducer["instance"], name)
			var initial_state = _reducers[name].call_func(_state[name], {"type": null})
			_state[name] = initial_state

	if callbacks != null:
		for callback in callbacks:
			subscribe(callback["instance"], callback["name"])


func subscribe(target, method) -> void:
	connect("state_changed", target, method)


func unsubscribe(target, method) -> void:
	disconnect("state_changed", target, method)


func remotesync_dispatch(action) -> void:
	if get_tree().is_network_server():
		rpc("dispatch", action)


func remote_dispatch_id(action, id) -> void:
	if get_tree().is_network_server():
		rpc_id(id, "dispatch_remote", action)


remotesync func dispatch(action) -> void:
	for name in _reducers.keys():
		var state = _state[name]
		var next_state = _reducers[name].call_func(state, action)
		if next_state == null:
			_state.erase(name)
			emit_signal("state_changed", name, null)
		elif state != next_state:
			_state[name] = next_state
			emit_signal("state_changed", name, next_state)

remote func dispatch_remote(action) -> void:
	for name in _reducers.keys():
		var state = _state[name]
		var next_state = _reducers[name].call_func(state, action)
		if next_state == null:
			_state.erase(name)
			emit_signal("state_changed", name, null)
		elif state != next_state:
			_state[name] = next_state
			emit_signal("state_changed", name, next_state)


func state() -> Dictionary:
	return _state


func shallow_copy(dict) -> Dictionary:
	return shallow_merge(dict, {})


func shallow_merge(src_dict, dest_dict) -> Dictionary:
	for i in src_dict.keys():
		dest_dict[i] = src_dict[i]
	return dest_dict
