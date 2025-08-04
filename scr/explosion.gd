class_name Explosion
extends Area2D


var radius: float
var force: float
var points: int
var ttl: int = 1

@onready var coll: CollisionPolygon2D = $CollisionPolygon2D


@warning_ignore("shadowed_variable")
func init(radius: float, force: float, points: int):
    self.radius = radius
    self.points = points
    self.force = force


func _ready() -> void:
    print("make explosion")
    coll.set_deferred("polygon", PolygonUtil.generate_circle(radius, points))
    body_entered.connect(on_area_entered)


func _physics_process(_delta: float) -> void:
    if ttl > 0:
        ttl -= 1
    else:
        queue_free()


func on_area_entered(body: PhysicsBody2D):
    print("Explosion collided with: ", body.name)
    if body is TerrainChunk:
        collide_with_terrain(body as TerrainChunk)
    elif body is RigidBody2D:
        collide_with_body(body as RigidBody2D)
    queue_free()


func collide_with_terrain(chunk: TerrainChunk):
    chunk.clip.call_deferred(coll.polygon, global_position)


func collide_with_body(body: RigidBody2D):
    var to_body := body.global_position - global_position
    var distance := to_body.length()
    var strength := 1 - (distance / radius)
    var direction := to_body / distance
    body.apply_impulse(direction * strength * force)
