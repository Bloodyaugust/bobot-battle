extends Node2D
class_name Player

export var id: int
export var is_local_player: bool

var _action_stack: Array = []


func add_action(action: String):
	_action_stack.append(action)


func process_next_action():
	var _action = _action_stack.pop_front()

	match _action:
		PlayerActions.MOVE:
			position += Vector2(50, 0).rotated(rotation)
		PlayerActions.ROTATE_RIGHT:
			rotation_degrees += 90
		PlayerActions.ROTATE_LEFT:
			rotation_degrees -= 90
		# PlayerActions.FIRE:
		# 	rotation_degrees += 90


func _ready():
	pass
