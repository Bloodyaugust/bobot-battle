extends Camera2D

export var move_speed: float
export var zoom_speed: float

onready var _root: Viewport = $"/root"

var _drag_origin
var _position_tween_t: float = 0
var _target: Node2D
var _target_last_position: Vector2
var _zoom_level: float = 1

func set_target(new_target: Node2D):
	_target = new_target
	_target_last_position = _target.position
	_position_tween_t = 0


func _process(delta):
	if _target:
		if _target.position != _target_last_position:
			_target_last_position = _target.position
			_position_tween_t = 0
		elif _drag_origin == null:
			_position_tween_t = clamp(_position_tween_t + delta * move_speed, 0, 1)
			position = position.linear_interpolate(_target.position, _position_tween_t)

	if _drag_origin:
		position = _drag_origin - _root.get_mouse_position()


func _unhandled_input(event):
	if event is InputEventMouseButton and event.is_pressed():
		match event.button_index:
			BUTTON_WHEEL_UP:
				_zoom_level = clamp(_zoom_level - zoom_speed, 0.5, 2)
			BUTTON_WHEEL_DOWN:
				_zoom_level = clamp(_zoom_level + zoom_speed, 0.5, 2)

		zoom = Vector2(_zoom_level, _zoom_level)

	if event is InputEventMouseButton and event.button_index == BUTTON_MASK_LEFT:
		if event.is_pressed():
			_drag_origin = _root.get_mouse_position()
		else:
			_drag_origin = null
