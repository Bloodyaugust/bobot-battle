extends Node2D
class_name Map

export var map_rect: Rect2

onready var _map: Node = get_child(0)

onready var _grid_size: int = _map.get_meta("Grid X")
onready var _tile_size: int = _map.get_meta("tilewidth")
onready var _size: int = _map.get_meta("width")


func _ready():
	map_rect = Rect2(Vector2(0, 0), Vector2(_tile_size * _size, _tile_size * _size))
