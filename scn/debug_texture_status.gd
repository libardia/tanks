extends Label


@onready var terrain: Terrain = $"../../../Terrain"

var format: String


func _ready() -> void:
    format = text


func _process(_delta: float) -> void:
    var status := "OFF" if terrain.no_texture else "ON"
    text = format % ["F2", status]
