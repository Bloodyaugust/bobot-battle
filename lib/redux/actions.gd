extends Node

signal ui_click


func client_set_state(state: String) -> Dictionary:
	return {"type": action_types.CLIENT_SET_STATE, "state": state}


func client_set_map(map: String) -> Dictionary:
	return {"type": action_types.CLIENT_SET_MAP, "map": map}


func game_set_start_time(time: int) -> Dictionary:
	return {"type": action_types.GAME_SET_START_TIME, "time": time}


func game_set_state(state: String) -> Dictionary:
	return {"type": action_types.GAME_SET_STATE, "state": state}


func player_add_player(id: int) -> Dictionary:
	return {
		"type": action_types.PLAYER_ADD_PLAYER,
		"id": id,
		"player":
		{"health": 10, "position": Vector2(0, 0), "ready": false, "action_queue": [], "id": id}
	}


func player_set_action_queue(action_queue: Array, id: int) -> Dictionary:
	return {"type": action_types.PLAYER_SET_ACTION_QUEUE, "action_queue": action_queue, "id": id}


func player_set_health(health: float, id: int) -> Dictionary:
	return {"type": action_types.PLAYER_SET_HEALTH, "health": health, "id": id}


func player_set_position(position: Vector2, id: int) -> Dictionary:
	return {"type": action_types.PLAYER_SET_POSITION, "position": position, "id": id}


func player_set_ready(ready: bool, id: int) -> Dictionary:
	return {"type": action_types.PLAYER_SET_READY, "ready": ready, "id": id}
