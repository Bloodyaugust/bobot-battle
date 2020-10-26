extends Node2D

const offset: Vector2 = Vector2(0, -30)

onready var _label: Label = $"./Label"

var _player: Node2D


func set_player(player: Node2D):
	_player = player
	_label.text = str(_player.id)


func _process(_delta):
	if _player != null:
		position = _player.position + offset
