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

var _color: Color = Color.WHITE
var color: Color:
    get:
        return _color
    set(value):
        _color = value
        if view_polygon != null: view_polygon.color = value

var _texture: Texture2D
var texture: Texture2D:
    get:
        return _texture
    set(value):
        _texture = value
        if view_polygon != null: view_polygon.texture = value

var terrain: Terrain

@onready var view_polygon: Polygon2D = $View
@onready var coll_polygon: CollisionPolygon2D = $Collision


func _ready() -> void:
    # Run the setters of these props
    polygon = _polygon
    color = _color
    texture = _texture


func clip(other_poly: PackedVector2Array, other_global_position: Vector2):
    var offset_poly := PolygonUtil.offset(other_poly, to_local(other_global_position))
    var new_polys := PolygonUtil.clip_handle_holes(polygon, offset_poly)
    if new_polys.is_empty():
        print(name, " completely clipped, destroying.")
        queue_free()
    else:
        for i in new_polys.size():
            if i == 0:
                polygon = new_polys[i]
                terrain.destroy_if_small(self)
            else:
                terrain.add_chunk(new_polys[i])
