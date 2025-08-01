extends Node2D


@export var terrain_texture: Texture2D
@export var transparency_threshold: float = 0.1
@export var sector_size: int = 128
@export var debug_mode: bool = true
@export var show_original_polys: bool = false

var generator := TerrainGenerator.new()
var terrain_image: Image


func _ready() -> void:
    terrain_image = terrain_texture.get_image()
    terrain_image = terrain_image.get_region(terrain_image.get_used_rect())
    generator.begin_generate(terrain_image, transparency_threshold, terrain_progress, terrain_done)


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
        #var p2d := Polygon2D.new()
        #p2d.polygon = p
        #p2d.color = Color(randf(), randf(), randf())
        #p2d.position = terrain_image.get_size() / -2.0
        #add_child.call_deferred(p2d)


#func _ready() -> void:
    ## Create the normal and iverted bitmaps
    #var ground_bitmap := bitmap_from_texture(terrain_texture, transparency_threshold)
    #var ground_bitmap_inv := invert_bitmap(ground_bitmap)
    ## Polygons from the normal and inverted bitmaps
    #var polys := bitmap_to_polygons(ground_bitmap, epsilon)
    #var polys_inv := bitmap_to_polygons(ground_bitmap_inv, epsilon)
#
    #if debug_mode:
        #print("Polygons generated")
#
    #if debug_mode and show_original_polys:
        #var normalnode := Node2D.new()
        #normalnode.name = "Normal"
        #var invnode := Node2D.new()
        #invnode.name = "Inverted"
        #add_child(normalnode)
        #add_child(invnode)
        #for p in polys:
            #var p2d := Polygon2D.new()
            #p2d.polygon = p
            #p2d.color = Color.GREEN
            ##p2d.visible = false
            #p2d.position = ground_bitmap.get_size() / -2.0
            #normalnode.add_child(p2d)
        #for p in polys_inv:
            #var p2d := Polygon2D.new()
            #p2d.polygon = p
            #p2d.color = Color.RED
            ##p2d.visible = false
            #p2d.position = ground_bitmap.get_size() / -2.0
            #invnode.add_child(p2d)

    #var next_polys: = polys
    #var working_polys: Array[PackedVector2Array] = []
#
    #for pi in polys_inv:
        #working_polys = next_polys
        #next_polys = []
#
        #if debug_mode:
            #print("Checking an inverted polygon against ", working_polys.size(), " working polygons")
#
        #for i in working_polys.size():
            #var p := working_polys[i]
            #if PolygonUtil.completely_enclosed(pi, p):
                #if debug_mode:
                    #print("Found a hole")
                #var split_point := PolygonUtil.extents(pi).get_center()
                #var split := PolygonUtil.split(p, split_point)
                #for ps in [split.side_a, split.side_b]:
                    #for split_p in ps:
                        #var new_polys := Geometry2D.clip_polygons(split_p, pi)
                        #if debug_mode:
                            #print("Made ", new_polys.size(), " new polygons")
                        #if debug_mode:
                            #for np in new_polys:
                                #if Geometry2D.is_polygon_clockwise(np):
                                    #print("Terrain warning: clockwise polygon as result of clip.")
                        #next_polys.append_array(new_polys)
            #else:
                #print("Not a hole")
                #next_polys.append(p)

        #for p in next_polys:
            #var p2d := Polygon2D.new()
            #p2d.polygon = p
            #p2d.color = Color(randf(), randf(), randf())
            #add_child(p2d)


# Helper ===========================================================================================

func bitmap_from_texture(texture: Texture2D, alpha_threshold: float) -> BitMap:
    var bm := BitMap.new()
    var img := texture.get_image()
    bm.create_from_image_alpha(img.get_region(img.get_used_rect()), alpha_threshold)
    return bm


func invert_bitmap(bitmap: BitMap) -> BitMap:
    var inverted := BitMap.new()
    var input_size := bitmap.get_size()
    inverted.create(input_size)
    for y in input_size.y:
        for x in input_size.x:
            inverted.set_bit(x, y, !bitmap.get_bit(x, y))
    return inverted


func bitmap_to_polygons(bitmap: BitMap) -> Array[PackedVector2Array]:
    return bitmap.opaque_to_polygons(Rect2(Vector2(), bitmap.get_size()), 0)
