extends Node


func explode_at(global_position: Vector2, radius: float, force: float, polygon_points: int = 50) -> Explosion:
    var expl: Explosion = preload("res://obj/explosion.tscn").instantiate()
    expl.global_position = global_position
    expl.init(radius, force, polygon_points)
    get_tree().current_scene.add_child(expl)
    return expl
