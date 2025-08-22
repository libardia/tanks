extends PanelContainer


@export var default_terrain_texture: Texture2D

@onready var preview: TextureRect = $CenterContainer/VBoxContainer/TextureRect
@onready var tex_name: Label = $CenterContainer/VBoxContainer/TexName
@onready var tex_details: Label = $CenterContainer/VBoxContainer/Details


func _ready() -> void:
    set_texture(default_terrain_texture)


func _on_simple_pressed() -> void:
    set_texture(preload("res://img/ground02.ase"))


func _on_complex_pressed() -> void:
    set_texture(preload("res://img/ground01.ase"))


func _on_gunicorn_pressed() -> void:
    set_texture(preload("res://img/Gunicorn.png"))


func _on_custom_pressed() -> void:
    DisplayServer.file_dialog_show("Custom Terrain Image", "", "", false, DisplayServer.FILE_DIALOG_MODE_OPEN_FILE, ["*.png"], image_dialog)


func image_dialog(status: bool, selected_paths: PackedStringArray, _selected_filter_index: int) -> void:
    if status:
        var img := Image.load_from_file(selected_paths[0])
        var tex := ImageTexture.create_from_image(img)
        set_texture(tex, selected_paths[0])


func _on_start_pressed() -> void:
    LoadManager.load_scene("res://scn/level.tscn", preload("res://scn/loading_screen.tscn"), true)


func set_texture(texture: Texture2D, name_override: String = ""):
    CrossScene.terrain_texture = texture
    preview.texture = texture
    tex_name.text = name_override if name_override else texture.resource_path
    tex_details.text = str(texture.get_width(), " x ", texture.get_height(), " px")
