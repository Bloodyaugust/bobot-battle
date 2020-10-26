extends Node2D
class_name Player

signal action_stack_changed

export var health: int = 2
export var id: int
export var is_local_player: bool
export remotesync var ready: bool

onready var _map: Node2D = $"../../Map"
onready var _sprite: Sprite = $"./Sprite"

remotesync var _action_stack: Array = []
var _dead: bool = false

func add_action(action: String) -> bool:
	if _action_stack.size() < PlayerActions.MAX_ACTIONS_QUEUED:
		_action_stack.append(action)
		if is_local_player:
			rset("_action_stack", _action_stack)
			emit_signal("action_stack_changed")
		return true
	return false


func damage(amount: int):
	health -= amount


func get_action_stack() -> Array:
	return _action_stack


func get_rect() -> Rect2:
	return Rect2(position - Vector2(16, 16), Vector2(32, 32))


func process_action(index: int) -> String:
	var _action_string: String = ""

	if ! _dead:
		var _action = _action_stack[index]

		match _action:
			PlayerActions.MOVE:
				var _new_position: Vector2 = (
					position
					+ Vector2(PlayerActions.MOVE_DISTANCE, 0).rotated(rotation)
				)
				_move(_new_position)
				_action_string = "{action}{rotation}".format({"action": _action, "rotation": rotation_degrees})
			PlayerActions.ROTATE_RIGHT:
				rotation_degrees += 90
				_action_string = "{action}{rotation}".format({"action": _action, "rotation": rotation_degrees})
			PlayerActions.ROTATE_LEFT:
				rotation_degrees -= 90
				_action_string = "{action}{rotation}".format({"action": _action, "rotation": rotation_degrees})
			# PlayerActions.FIRE:
			# 	rotation_degrees += 90
	else:
		_action_string = "DEAD"
	if is_local_player:
		emit_signal("action_stack_changed")

	return _action_string


func set_ready(is_ready: bool):
	if is_local_player:
		rset("ready", is_ready)


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


func _on_store_changed(name, state):
	match name:
		"game":
			if state.state == GameStates.CHOOSING:
				rset("_action_stack", [])
				emit_signal("action_stack_changed")
			if state.state == GameStates.CHOOSING && _dead:
				rset("ready", true)


func _process(_delta):
	if ! _dead && health <= 0:
		_dead = true
		_sprite.modulate = Color(0.5, 0.5, 0.5)


func _ready():
	if is_local_player:
		store.subscribe(self, "_on_store_changed")
