extends Node2D


@export var terrain_texture: Texture2D
@export var transparency_threshold: float = 0.1
@export var chunk_size: int = 128
@export var debug_mode: bool = true
@export var show_original_polys: bool = false

var generator := TerrainGenerator.new()
var terrain_image: Image


func _ready() -> void:
    terrain_image = terrain_texture.get_image()
    terrain_image = terrain_image.get_region(terrain_image.get_used_rect())

    generator.progress.connect(terrain_progress)
    generator.done.connect(terrain_done)
    generator.begin_generate(terrain_image, transparency_threshold, chunk_size)


func terrain_progress(value: float):
    print("Progress: ", value)


func terrain_done(polys: Array[PackedVector2Array]):
    print("Terrain done with ", polys.size(), " polygons")
    for p in polys:
        var chunk: TerrainChunk = preload("res://obj/terrain-chunk.tscn").instantiate()
        chunk.polygon = p
        chunk.color = Color(randf(), randf(), randf())
        chunk.position = terrain_image.get_size() / -2.0
        add_child.call_deferred(chunk)
