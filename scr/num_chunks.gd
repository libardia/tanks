extends Label


@onready var terrain: Terrain = $"../../../Terrain"

var format: String


func _ready() -> void:
    format = text


func _process(_delta: float) -> void:
    text = format % terrain.get_child_count()
