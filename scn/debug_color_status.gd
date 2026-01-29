extends Label


@onready var terrain: Terrain = $"../../../Terrain"

var format: String


func _ready() -> void:
    format = text


func _process(_delta: float) -> void:
    var status := "ON" if terrain.debug_colors else "OFF"
    text = format % ["F1", status]
