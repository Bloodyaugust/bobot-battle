extends Node

signal ui_click


func game_set_start_time(time) -> Dictionary:
	return {"type": action_types.GAME_SET_START_TIME, "time": time}


func player_set_health(health) -> Dictionary:
	return {"type": action_types.PLAYER_SET_HEALTH, "health": health}


func player_set_position(position) -> Dictionary:
	return {"type": action_types.PLAYER_SET_POSITION, "position": position}
