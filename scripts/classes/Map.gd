extends Node2D
class_name Map

export var map_rect: Rect2
export var spawn_points: Array

var _map: Node

var _grid_size: int
var _hazards_root: Node
var _tile_size: int
var _size: int

var _hazards: Array


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


func _initialize():
	_map = get_child(0)

	_map.position += Vector2(0, 16)

	_grid_size = _map.get_meta("Grid X")
	_hazards_root = _map.find_node("hazards")
	_tile_size = _map.get_meta("tilewidth")
	_size = _map.get_meta("width")

	_hazards = _hazards_root.get_children()

	map_rect = Rect2(Vector2(0, 0), Vector2(_tile_size * _size, _tile_size * _size))
	spawn_points = _map.find_node("spawns").get_children()

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

	store.emit_signal("map_loaded")


func _ready():
	add_child(
		load("res://tilesets/maps/{map}.tmx".format({"map": store.state()["client"]["map"]})).instance()
	)

	_initialize()
