extends LoadingScreen


@export var bar_width_ratio: float = 0.75

@onready var contents: VBoxContainer = $PanelContainer/VBoxContainer
@onready var panel: PanelContainer = $PanelContainer


func _process(_delta: float) -> void:
    var vp_size = get_viewport().size
    panel.position = Vector2.ZERO
    panel.size = vp_size
    contents.custom_minimum_size.x = vp_size.x * bar_width_ratio
