extends StaticBody2D


@onready var view_polygon: Polygon2D = $View
@onready var coll_polygon: CollisionPolygon2D = $Collision

var polygon: PackedVector2Array


func _ready() -> void:
    pass
