extends Node2D
class_name Player

export var id: int
export var is_local_player: bool

onready var _map: Node2D = $"../Map"

var _action_stack: Array = []


func add_action(action: String) -> bool:
	if _action_stack.size() < PlayerActions.MAX_ACTIONS_QUEUED:
		_action_stack.append(action)
		store.dispatch(actions.player_set_action_queue(_action_stack, id))
		return true
	return false


func get_rect() -> Rect2:
	return Rect2(position - Vector2(16, 16), Vector2(32, 32))


func process_next_action() -> bool:
	var _action = _action_stack.pop_front()

	match _action:
		PlayerActions.MOVE:
			var _new_position: Vector2 = (
				position
				+ Vector2(PlayerActions.MOVE_DISTANCE, 0).rotated(rotation)
			)
			_move(_new_position)
		PlayerActions.ROTATE_RIGHT:
			rotation_degrees += 90
		PlayerActions.ROTATE_LEFT:
			rotation_degrees -= 90
		# PlayerActions.FIRE:
		# 	rotation_degrees += 90

	store.dispatch(actions.player_set_action_queue(_action_stack, id))

	return _action_stack.size() > 0


func _move(to: Vector2):
	if ! _map.valid_for_move(to):
		return

	var _players: Array = get_tree().get_nodes_in_group("player")
	for _player in _players:
		if _player.get_rect().has_point(to):
			var _new_player_position: Vector2 = (
				_player.position
				+ Vector2(PlayerActions.MOVE_DISTANCE, 0).rotated(rotation)
			)
			if _map.valid_for_move(_new_player_position):
				for _player_nested in _players:
					if _player_nested.get_rect().has_point(_new_player_position):
						return
				_player.position = _new_player_position
			else:
				return

	position = to


func _ready():
	pass
