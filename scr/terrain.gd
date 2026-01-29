class_name Terrain
extends Node2D


@export var transparency_threshold: float = 0.75
@export var chunk_size: int = 128
@export var minimum_chunk_area: float = 10
@export_category("Debug")
@export var debug_colors: bool = false:
    get:
        return debug_colors
    set(value):
        debug_colors = value
        change_debug_colors.emit(value)
@export var no_texture: bool = false:
    get:
        return no_texture
    set(value):
        no_texture = value
        change_debug_disable_texture.emit(value)


signal change_debug_colors(debug_colors: bool)
signal change_debug_disable_texture(disable_texture: bool)


var terrain_texture: Texture2D
var chunk_scene: PackedScene = preload("res://obj/terrain_chunk.tscn")
var generator := TerrainGenerator.new()
var terrain_image: Image
var chunk_index: int = 0


func _ready() -> void:
    LoadManager.register_node_waiting(self)
    LoadManager.set_message("Generating terrain...")
    terrain_texture = CrossScene.terrain_texture
    terrain_image = terrain_texture.get_image()
    position = terrain_image.get_size() / -2.0
    generator.progress.connect(terrain_progress)
    generator.done.connect(terrain_done)
    generator.begin_generate(terrain_image, transparency_threshold, chunk_size)


func _unhandled_input(event: InputEvent) -> void:
    if event.is_action_pressed("debug-colors"):
        debug_colors = not debug_colors
    elif event.is_action_pressed("debug-disable-texture"):
        no_texture = not no_texture


func terrain_progress(value: float):
    LoadManager.report_node_progress(self, value)


func terrain_done(polys: Array[PackedVector2Array]):
    print("Terrain done with ", polys.size(), " polygons")
    for p in polys:
        add_chunk(p)
    LoadManager.report_node_done(self)


func add_chunk(polygon: PackedVector2Array):
    if check_too_small(polygon):
        print("Skipped creating terrain chunk for being too small")
        return
    var chunk: TerrainChunk = chunk_scene.instantiate()
    chunk.terrain = self
    change_debug_colors.connect.call_deferred(chunk.set_debug_color)
    change_debug_disable_texture.connect.call_deferred(chunk.set_debug_texture_disabled)
    chunk.polygon = polygon
    if debug_colors:
        chunk.color = chunk.debug_color
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
