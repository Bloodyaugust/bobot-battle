extends Node


func game(state, action) -> Dictionary:
	if action["type"] == action_types.GAME_SET_START_TIME:
		var next_state = store.shallow_copy(state)
		next_state["start_time"] = action["time"]
		return next_state
	return state


func player(state, action) -> Dictionary:
	if action["type"] == action_types.PLAYER_SET_HEALTH:
		var next_state = store.shallow_copy(state)
		next_state["health"] = action["health"]
		return next_state
	if action["type"] == action_types.PLAYER_SET_POSITION:
		var next_state = store.shallow_copy(state)
		next_state["tile"] = action["tile"]
		return next_state
	return state
