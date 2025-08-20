class_name Terrain
extends Node2D


@export var terrain_texture: Texture2D
@export var transparency_threshold: float = 0.75
@export var chunk_size: int = 128
@export var minimum_chunk_area: float = 10
@export_category("Debug")
@export var debug_colors: bool = false
@export var no_texture: bool = false

var chunk_scene: PackedScene = preload("res://obj/terrain_chunk.tscn")
var generator := TerrainGenerator.new()
var terrain_image: Image
var chunk_index: int = 0


func _ready() -> void:
    terrain_image = terrain_texture.get_image()
    position = terrain_image.get_size() / -2.0
    generator.progress.connect(terrain_progress)
    generator.done.connect(terrain_done)
    generator.begin_generate(terrain_image, transparency_threshold, chunk_size)


func terrain_progress(value: float):
    print("Progress: ", value)


func terrain_done(polys: Array[PackedVector2Array]):
    print("Terrain done with ", polys.size(), " polygons")
    for p in polys:
        add_chunk(p)


func add_chunk(polygon: PackedVector2Array):
    if check_too_small(polygon):
        print("Skipped creating terrain chunk for being too small")
        return
    var chunk: TerrainChunk = chunk_scene.instantiate()
    chunk.terrain = self
    chunk.polygon = polygon
    if debug_colors:
        chunk.color = Color(randf(), randf(), randf())
    if not no_texture:
        chunk.texture = terrain_texture
    chunk.name = str("TerrainChunk", chunk_index)
    chunk_index += 1
    add_child.call_deferred(chunk)


func check_too_small(polygon: PackedVector2Array) -> bool:
    var area := PolygonUtil.area(polygon)
    if area < minimum_chunk_area:
        print("Polygon is too small, area = ", area)
        return true
    return false


func destroy_if_small(chunk: TerrainChunk):
    if check_too_small(chunk.polygon):
        print("Destroying ", chunk.name, " for being too small")
        chunk.queue_free()
