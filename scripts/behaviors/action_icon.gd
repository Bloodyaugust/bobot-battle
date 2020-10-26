extends TextureRect

var _fire_texture: Texture = preload("res://sprites/fire.png")
var _move_texture: Texture = preload("res://sprites/move_forward.png")
var _rotate_right_texture: Texture = preload("res://sprites/rotate_right.png")
var _rotate_left_texture: Texture = preload("res://sprites/rotate_left.png")


func update_texture(action: String):
	var _new_texture: Texture

	match action:
		PlayerActions.FIRE:
			_new_texture = _fire_texture
		PlayerActions.MOVE:
			_new_texture = _move_texture
		PlayerActions.ROTATE_LEFT:
			_new_texture = _rotate_left_texture
		PlayerActions.ROTATE_RIGHT:
			_new_texture = _rotate_right_texture

	set_texture(_new_texture)
