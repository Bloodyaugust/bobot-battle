extends Node2D
class_name Map

export var map_rect: Rect2

onready var _map: Node = get_child(0)

onready var _grid_size: int = _map.get_meta("Grid X")
onready var _hazards_root: Node = _map.find_node("hazards")
onready var _tile_size: int = _map.get_meta("tilewidth")
onready var _size: int = _map.get_meta("width")

onready var _hazards: Array = _hazards_root.get_children()


func resolve_hazard_actions(player: Player):
	for _hazard in _hazards:
		var _hazard_type = _hazard.get_meta("scene")

		match _hazard_type:
			"zap":
				if _hazard.get_meta("rect").has_point(player.position):
					store.dispatch(
						actions.player_set_health(
							store.state()["player"][player.id]["health"] - 1, player.id
						)
					)


func valid_for_move(move_to: Vector2) -> bool:
	if ! map_rect.has_point(move_to):
		return false

	for _hazard in _hazards:
		if _hazard.get_meta("scene") != "wall":
			continue

		print(_hazard.position.x)
		print(_hazard.region_rect.size.x)

		var _hazard_rect = _hazard.get_meta("rect")

		if _hazard_rect.has_point(move_to):
			return false

	return true


func _ready():
	map_rect = Rect2(Vector2(0, 0), Vector2(_tile_size * _size, _tile_size * _size))

	for _hazard in _hazards:
		_hazard.centered = true
		_hazard.position += Vector2(_hazard.region_rect.size.x / 2, -_hazard.region_rect.size.y / 2)

		_hazard.set_meta(
			"rect",
			Rect2(
				Vector2(
					_hazard.position.x - _hazard.region_rect.size.x,
					_hazard.position.y - _hazard.region_rect.size.y
				),
				Vector2(PlayerActions.MOVE_DISTANCE, PlayerActions.MOVE_DISTANCE)
			)
		)
