extends Sprite

export var time_scalar: float
export var size_scalar: float

onready var _beginning_component_value: float = scale.x


func _process(_delta):
	var _current_component_value = (
		_beginning_component_value
		+ sin(OS.get_ticks_msec() * time_scalar) * size_scalar
	)

	scale = Vector2(_current_component_value, _current_component_value)
