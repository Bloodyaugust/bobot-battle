extends CanvasLayer

export var action_component: PackedScene

onready var _action_button_container = $"./EnqueueActionsContainer/CenterContainer/ActionButtonContainer"
onready var _queued_actions_vbox = $"./QueuedActionsContainer/CenterContainer/VBoxContainer/CenterContainer2/QueuedActions"
onready var _game_state_label: Label = $"./QueuedActionsContainer/CenterContainer/VBoxContainer/CenterContainer3/GameState"
onready var _fire_button: BaseButton = _action_button_container.get_node("./Fire")
onready var _move_button: BaseButton = _action_button_container.get_node("./Move")
onready var _rotate_right_button: BaseButton = _action_button_container.get_node("./RotateRight")
onready var _rotate_left_button: BaseButton = _action_button_container.get_node("./RotateLeft")
onready var _ready_button = $"./QueuedActionsContainer/CenterContainer/VBoxContainer/CenterContainer/Ready"

var _local_player: Player


func G(arr) -> GGArray:
	return GG.arr(arr)


func _is_local_player_dead() -> bool:
	if _local_player == null:
		return false

	return _local_player.dead


func _set_buttons_disabled(disabled: bool):
	_fire_button.disabled = disabled
	_move_button.disabled = disabled
	_rotate_left_button.disabled = disabled
	_rotate_right_button.disabled = disabled


func _on_local_player_action_stack_changed():
	var _local_player_action_stack = _local_player.get_action_stack()

	GDUtil.free_children(_queued_actions_vbox)

	for _action in _local_player_action_stack:
		_queued_actions_vbox.add_child(action_component.instance())

	_ready_button.disabled = (
		(_local_player_action_stack.size() < PlayerActions.MAX_ACTIONS_QUEUED)
		|| (_local_player.ready || store.state()["game"]["state"] == GameStates.RESOLVING)
	)


func _on_local_player_spawned():
	_local_player = G(get_tree().get_nodes_in_group("player")).find(
		"player => player.is_local_player"
	)

	_local_player.connect("action_stack_changed", self, "_on_local_player_action_stack_changed")


func _on_fire_button_pressed():
	if _local_player:
		_local_player.add_action(PlayerActions.FIRE)


func _on_move_button_pressed():
	if _local_player:
		_local_player.add_action(PlayerActions.MOVE)


func _on_rotate_right_button_pressed():
	if _local_player:
		_local_player.add_action(PlayerActions.ROTATE_RIGHT)


func _on_rotate_left_button_pressed():
	if _local_player:
		_local_player.add_action(PlayerActions.ROTATE_LEFT)


func _on_ready_button_pressed():
	_local_player.set_ready(true)
	_ready_button.disabled = true


func _on_store_changed(name, state):
	match name:
		"client":
			if state["state"] == ClientConstants.MENU:
				offset.y = 2000
			else:
				offset.y = 0

		"game":
			_game_state_label.text = state["state"]
			_set_buttons_disabled(state["state"] == GameStates.RESOLVING || _is_local_player_dead())

			if state["state"] == GameStates.RESOLVING:
				_local_player.set_ready(false)


# Called when the node enters the scene tree for the first time.
func _ready():
	GDUtil.free_children(_queued_actions_vbox)

	_fire_button.connect("pressed", self, "_on_fire_button_pressed")
	_move_button.connect("pressed", self, "_on_move_button_pressed")
	_rotate_right_button.connect("pressed", self, "_on_rotate_right_button_pressed")
	_rotate_left_button.connect("pressed", self, "_on_rotate_left_button_pressed")
	_ready_button.connect("pressed", self, "_on_ready_button_pressed")

	store.connect("local_player_spawned", self, "_on_local_player_spawned")
	store.subscribe(self, "_on_store_changed")

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
