extends Node2D
class_name Map

export var map_rect: Rect2

onready var _map: Node = get_child(0)

onready var _grid_size: int = _map.get_meta("Grid X")
onready var _hazards_root: Node = _map.find_node("hazards")
onready var _tile_size: int = _map.get_meta("tilewidth")
onready var _size: int = _map.get_meta("width")

onready var _hazards: Array = _hazards_root.get_children()


func valid_for_move(move_to: Vector2) -> bool:
	if ! map_rect.has_point(move_to):
		return false

	for _hazard in _hazards:
		if _hazard.get_meta("scene") != "wall":
			continue

		print(_hazard.position.x)
		print(_hazard.region_rect.size.x)

		var _hazard_rect = Rect2(
			Vector2(
				_hazard.position.x - _hazard.region_rect.size.x,
				_hazard.position.y - _hazard.region_rect.size.y
			),
			Vector2(PlayerActions.MOVE_DISTANCE, PlayerActions.MOVE_DISTANCE)
		)

		if _hazard_rect.has_point(move_to):
			return false

	return true


func _ready():
	map_rect = Rect2(Vector2(0, 0), Vector2(_tile_size * _size, _tile_size * _size))

	for _hazard in _hazards:
		_hazard.centered = true
		_hazard.position += Vector2(_hazard.region_rect.size.x / 2, -_hazard.region_rect.size.y / 2)
