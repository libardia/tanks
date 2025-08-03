extends RigidBody2D


var _fuse_time: float
var fuse_time: float:
    get:
        return _fuse_time
    set(value):
        _fuse_time = value
        if fuse_timer != null: fuse_timer.wait_time = value

@onready var fuse_timer: Timer = $FuseTimer


func _ready() -> void:
    fuse_time = _fuse_time
