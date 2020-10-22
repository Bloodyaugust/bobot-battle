extends Node

signal ui_click


func game_set_start_time(time) -> Dictionary:
	return {"type": action_types.GAME_SET_START_TIME, "time": time}


func game_set_state(state) -> Dictionary:
	return {"type": action_types.GAME_SET_STATE, "state": state}


func player_set_action_queue(action_queue) -> Dictionary:
	return {"type": action_types.PLAYER_SET_ACTION_QUEUE, "action_queue": action_queue}


func player_set_health(health) -> Dictionary:
	return {"type": action_types.PLAYER_SET_HEALTH, "health": health}


func player_set_position(position) -> Dictionary:
	return {"type": action_types.PLAYER_SET_POSITION, "position": position}
