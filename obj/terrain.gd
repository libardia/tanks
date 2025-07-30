extends Node2D


@export var ground_texture: Texture2D
@export var transparency_threshold: float = 0.1
@export var epsilon: float = 0
@export var sector_size: int = 128


func _ready() -> void:
    # image from texture
    var ground_image := ground_texture.get_image()
    # crop image to only nonzero alpha pixels
    ground_image = ground_image.get_region(ground_image.get_used_rect())
    # create bitmap from image
    var ground_bitmap := BitMap.new()
    ground_bitmap.create_from_image_alpha(ground_image, transparency_threshold)
    # create inverted bitmap
    var ground_bitmap_invert := BitMap.new()
    ground_bitmap_invert.create(ground_bitmap.get_size())
    for y in ground_bitmap.get_size().y:
        for x in ground_bitmap.get_size().x:
            ground_bitmap_invert.set_bit(x, y, !ground_bitmap.get_bit(x, y))
    # get polygons from bitmaps
    var polys := ground_bitmap.opaque_to_polygons(Rect2(Vector2(), ground_bitmap.get_size()), epsilon)
    var ipolys := ground_bitmap_invert.opaque_to_polygons(Rect2(Vector2(), ground_bitmap.get_size()), epsilon)
    # set polygons for display
    print("Polys: ", polys.size(), "\nIPolys: ", ipolys.size())
    for ps in [polys, ipolys]:
        var node = Node2D.new()
        add_child(node)
        for p in ps:
            var np := Polygon2D.new()
            np.polygon = p
            np.offset = ground_image.get_used_rect().size / -2.0
            np.color = Color(randf(), randf(), randf(), 1)
            node.add_child(np)
