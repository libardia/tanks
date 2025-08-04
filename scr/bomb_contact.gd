extends RigidBody2D


@export var explosion_size: float = 100
@export var explosion_force: float = 500


func _ready() -> void:
    body_entered.connect(explode)


func explode(_body):
    ExplosionSpawner.explode_at(global_position, explosion_size, explosion_force)
    queue_free()
