extends Node2D
class_name Player

export var id: int
export var is_local_player: bool

onready var _map: Node2D = $"../Map"

var _action_stack: Array = []


func add_action(action: String) -> bool:
	if _action_stack.size() < PlayerActions.MAX_ACTIONS_QUEUED:
		_action_stack.append(action)
		store.dispatch(actions.player_set_action_queue(_action_stack))
		return true
	return false


func process_next_action() -> bool:
	var _action = _action_stack.pop_front()

	match _action:
		PlayerActions.MOVE:
			var _new_position: Vector2 = position + Vector2(32, 0).rotated(rotation)
			if _map.map_rect.has_point(_new_position):
				position = _new_position
		PlayerActions.ROTATE_RIGHT:
			rotation_degrees += 90
		PlayerActions.ROTATE_LEFT:
			rotation_degrees -= 90
		# PlayerActions.FIRE:
		# 	rotation_degrees += 90

	store.dispatch(actions.player_set_action_queue(_action_stack))

	return _action_stack.size() > 0


func _ready():
	pass
