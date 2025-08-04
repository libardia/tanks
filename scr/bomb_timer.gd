extends RigidBody2D


@export var fuse_time_seconds: int = 5
@export var explosion_size: float = 100
@export var explosion_force: float = 500

@onready var animations: AnimationPlayer = $AnimationPlayer
@onready var timer_label: Label = $TimerLabel
@onready var fuse_timer: Timer = $FuseTimer


func _ready() -> void:
    animations.play("blink")
    fuse_timer.start(fuse_time_seconds)
    fuse_timer.timeout.connect(explode)


func _process(_delta: float) -> void:
    timer_label.text = str(ceili(fuse_timer.time_left))


func explode():
    ExplosionSpawner.explode_at(global_position, explosion_size, explosion_force)
    queue_free()
