extends Area2D


@export var radius := 10.0
@export var points := 20

@onready var view: Polygon2D = $Polygon2D
@onready var coll: CollisionPolygon2D = $CollisionPolygon2D


func _ready() -> void:
    var circle := PolygonUtil.generate_circle(radius, points)
    view.polygon = circle
    coll.polygon = circle


func _process(_delta: float) -> void:
    global_position = get_viewport().get_camera_2d().get_global_mouse_position()


func _unhandled_input(event: InputEvent) -> void:
    if event is InputEventMouseButton:
        var iemb: InputEventMouseButton = event
        if iemb.button_index == MOUSE_BUTTON_LEFT and iemb.pressed:
            for b in get_overlapping_bodies():
                if b is TerrainChunk:
                    var t: TerrainChunk = b
                    t.clip(PolygonUtil.offset(coll.polygon, t.to_local(global_position)))
