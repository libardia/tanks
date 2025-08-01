class_name TerrainChunk
extends StaticBody2D


var _polygon: PackedVector2Array
var polygon: PackedVector2Array:
    get:
        return _polygon
    set(value):
        _polygon = value
        if view_polygon != null: view_polygon.polygon = value
        if coll_polygon != null: coll_polygon.polygon = value
var _color: Color
var color: Color:
    get:
        return _color
    set(value):
        _color = value
        if view_polygon != null: view_polygon.color = value


@onready var view_polygon: Polygon2D = $View
@onready var coll_polygon: CollisionPolygon2D = $Collision

func _ready() -> void:
    # Run the setters of these props
    polygon = _polygon
    color = _color
