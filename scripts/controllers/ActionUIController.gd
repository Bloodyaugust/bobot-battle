extends CanvasLayer

export var action_component: PackedScene

onready var _action_button_container = $"./EnqueueActionsContainer/CenterContainer/ActionButtonContainer"
onready var _queued_actions_vbox = $"./QueuedActionsContainer/CenterContainer/VBoxContainer/CenterContainer2/QueuedActions"
onready var _move_button: BaseButton = _action_button_container.get_node("./Move")
onready var _rotate_right_button: BaseButton = _action_button_container.get_node("./RotateRight")
onready var _rotate_left_button: BaseButton = _action_button_container.get_node("./RotateLeft")
onready var _ready_button = $"./QueuedActionsContainer/CenterContainer/VBoxContainer/CenterContainer/Ready"

var _local_player: Player


func G(arr) -> GGArray:
	return GG.arr(arr)


func _on_move_button_pressed():
	_local_player.add_action(PlayerActions.MOVE)


func _on_rotate_right_button_pressed():
	_local_player.add_action(PlayerActions.ROTATE_RIGHT)


func _on_rotate_left_button_pressed():
	_local_player.add_action(PlayerActions.ROTATE_LEFT)


func _on_ready_button_pressed():
	while _local_player.process_next_action():
		pass


func _on_store_changed(name, state):
	match name:
		"player":
			GDUtil.free_children(_queued_actions_vbox)

			for _action in state.action_queue:
				_queued_actions_vbox.add_child(action_component.instance())


# Called when the node enters the scene tree for the first time.
func _ready():
	_local_player = G(get_tree().get_nodes_in_group("player")).find(
		"player => player.is_local_player"
	)

	_move_button.connect("pressed", self, "_on_move_button_pressed")
	_rotate_right_button.connect("pressed", self, "_on_rotate_right_button_pressed")
	_rotate_left_button.connect("pressed", self, "_on_rotate_left_button_pressed")
	_ready_button.connect("pressed", self, "_on_ready_button_pressed")

	store.subscribe(self, "_on_store_changed")

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
