extends CanvasLayer

onready var action_button_container = $"./MarginContainer/CenterContainer/ActionButtonContainer"
onready var move_button: BaseButton = action_button_container.get_node("./Move")
onready var rotate_right_button: BaseButton = action_button_container.get_node("./RotateRight")
onready var rotate_left_button: BaseButton = action_button_container.get_node("./RotateLeft")

var _local_player: Player


func G(arr) -> GGArray:
	return GG.arr(arr)


func _on_move_button_pressed():
	_local_player.add_action(PlayerActions.MOVE)
	_local_player.process_next_action()


func _on_rotate_right_button_pressed():
	_local_player.add_action(PlayerActions.ROTATE_RIGHT)
	_local_player.process_next_action()


func _on_rotate_left_button_pressed():
	_local_player.add_action(PlayerActions.ROTATE_LEFT)
	_local_player.process_next_action()


# Called when the node enters the scene tree for the first time.
func _ready():
	_local_player = G(get_tree().get_nodes_in_group("player")).find(
		"player => player.is_local_player"
	)

	move_button.connect("pressed", self, "_on_move_button_pressed")
	rotate_right_button.connect("pressed", self, "_on_rotate_right_button_pressed")
	rotate_left_button.connect("pressed", self, "_on_rotate_left_button_pressed")

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
