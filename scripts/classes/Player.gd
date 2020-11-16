extends Node2D
class_name Player

signal action_stack_changed

export var dead: bool = false
export var health: int = 2
export var id: int
export var is_local_player: bool
export remotesync var ready: bool

export var _shot_hit_effect: PackedScene

onready var _active_player_indicator: Sprite = $"./ActivePlayerIndicator"
onready var _fire_animation: AnimatedSprite = $"./FireAnimation"
onready var _map: Node2D = $"../../Map"
onready var _sprite: Sprite = $"./Body"

remotesync var _action_stack: Array = []

func add_action(action: String) -> bool:
	if _action_stack.size() < PlayerActions.MAX_ACTIONS_QUEUED:
		_action_stack.append(action)
		if is_local_player:
			rset("_action_stack", _action_stack) # If we are a client, this is not guaranteed to get to all other clients, change to server authoritative
			emit_signal("action_stack_changed")
		return true
	return false


func damage(amount: int):
	health -= amount

	if health <= 0 && ! dead:
		dead = true

		if is_local_player:
			_sprite.modulate = Color(0.116791, 0.347656, 0)
		else:
			_sprite.modulate = Color(0.5, 0.5, 0.5)


func get_action_stack() -> Array:
	return _action_stack


func get_rect() -> Rect2:
	return Rect2(position - Vector2(16, 16), Vector2(32, 32))


func _on_fire_animation_finished() -> void:
	_fire_animation.hide()
	_fire_animation.frame = 0


func process_action(index: int) -> String:
	var _action_string: String = ""

	if ! dead:
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
			PlayerActions.FIRE:
				_action_string = _fire()
	else:
		_action_string = "DEAD"
	if is_local_player:
		emit_signal("action_stack_changed")

	return _action_string


func set_ready(is_ready: bool):
	if is_local_player:
		rset("ready", is_ready)


func _fire() -> String:
	var _fire_string: String = ""
	var _players: Array = get_tree().get_nodes_in_group("player")
	var _testing_point: Vector2 = position + Vector2(PlayerActions.MOVE_DISTANCE, 0).rotated(rotation)
	var _new_hit_effect: Node2D = _shot_hit_effect.instance()

	_fire_animation.show()
	_fire_animation.play()
	
	while _map.valid_for_move(_testing_point):
		for _player in _players:
			if _player.get_rect().has_point(_testing_point):
				_player.damage(1)
				_new_hit_effect.position = _testing_point
				get_tree().get_root().add_child(_new_hit_effect)
				return "FIRE-{rotation}-HIT{id}".format({"rotation": rotation_degrees, "id": _player.id})

		_testing_point += Vector2(PlayerActions.MOVE_DISTANCE, 0).rotated(rotation)

	_new_hit_effect.position = _testing_point

	get_tree().get_root().add_child(_new_hit_effect)

	return "MISS-{rotation}".format({"rotation": rotation_degrees})


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
			if state.state == GameStates.CHOOSING && dead:
				rset("ready", true)


func _ready():
	_fire_animation.connect("animation_finished", self, "_on_fire_animation_finished")

	if is_local_player:
		store.subscribe(self, "_on_store_changed")
		_active_player_indicator.visible = true
		_sprite.modulate = Color(0.521569, 0.956863, 0.486275)

		get_tree().get_root().find_node("GameCamera", true, false).set_target(self)
