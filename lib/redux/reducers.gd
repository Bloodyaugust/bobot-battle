extends Node


func game(state, action) -> Dictionary:
	if action["type"] == action_types.GAME_SET_START_TIME:
		var next_state = store.shallow_copy(state)
		next_state["start_time"] = action["time"]
		return next_state
	if action["type"] == action_types.GAME_SET_STATE:
		var next_state = store.shallow_copy(state)
		next_state["state"] = action["state"]
		return next_state
	return state


func player(state, action) -> Dictionary:
	if action["type"] == action_types.PLAYER_ADD_PLAYER:
		var next_state = store.shallow_copy(state)
		next_state[action["id"]] = action["player"]
		return next_state
	if action["type"] == action_types.PLAYER_SET_ACTION_QUEUE:
		var next_state = store.shallow_copy(state)
		next_state[action["id"]]["action_queue"] = action["action_queue"]
		return next_state
	if action["type"] == action_types.PLAYER_SET_HEALTH:
		var next_state = store.shallow_copy(state)
		next_state[action["id"]]["health"] = action["health"]
		return next_state
	if action["type"] == action_types.PLAYER_SET_POSITION:
		var next_state = store.shallow_copy(state)
		next_state[action["id"]]["position"] = action["position"]
		return next_state
	if action["type"] == action_types.PLAYER_SET_READY:
		var next_state = store.shallow_copy(state)
		next_state[action["id"]]["ready"] = action["ready"]
		return next_state
	return state
