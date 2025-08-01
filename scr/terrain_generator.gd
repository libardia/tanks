class_name TerrainGenerator

const _POLY_EPSILON := 0.0
var _gen_thread := Thread.new()

# State ============================================================================================

var _source_image: Image
var _transparency_threshold: float
var _progress_callback: Callable
var _done_callback: Callable
var _ground_bitmap_t: BitMap = BitMap.new()
var _ground_bitmap_n: BitMap = BitMap.new()
var _polys_t: Array[PackedVector2Array]
var _polys_n: Array[PackedVector2Array]
var _original_n_size: float

# Entry ============================================================================================

func begin_generate(source_image: Image, transparency_threshold: float, progress_callback: Callable, done_callback: Callable):
    _source_image = source_image
    _transparency_threshold = transparency_threshold
    _progress_callback = progress_callback
    _done_callback = done_callback
    _gen_thread.start(_generate)

# Main generate function ===========================================================================

func _generate():
    _progress_callback.call(0.0)

    # Anything marked "t" is part of the TERRAIN
    # Anything marked "n" is part of NEGATIVE SPACE

    # Create the normal and iverted bitmaps
    _ground_bitmap_t.create_from_image_alpha(_source_image, _transparency_threshold)
    _ground_bitmap_n = _invert_bitmap(_ground_bitmap_t)

    # Polygons from the normal and inverted bitmaps
    _polys_t = _bitmap_to_polygons(_ground_bitmap_t)
    _polys_n = _bitmap_to_polygons(_ground_bitmap_n)

    print("T-polys: ", _polys_t.size())
    print("N-polys: ", _polys_n.size())

    _original_n_size = _polys_n.size()

    # Step 1: remove n-polys that represent only negative space; specifically,
    # n-polys that are not enclosed by any t-poly
    _remove_negative_space()

    # Keep repeating step 2 until no changes are made
    var should_continue := true
    while should_continue:
        # Step 2: Check each n-poly; if it is enclosed by exactly one t-poly,
        # split the T into Ta and Tb; clip N from Ta and from Tb; remove T and
        # N from their lists; add the results of the cuts to the T list
        should_continue = _cut_next_level()

    _progress_callback.call(1.0)
    _done_callback.call(_polys_t)

# Stages ===========================================================================================

func _remove_negative_space():
    # Remove purely negative space
    # (loop is done this way to allow for concurrent modification)
    var i := 0
    while i < _polys_n.size():
        var pn_i := _polys_n[i]
        var none_enclose := true
        for pt in _polys_t:
            if PolygonUtil.completely_enclosed(pn_i, pt):
                none_enclose = false
                break
        if none_enclose:
            # if NO t-polys completely enclose this n-poly, it must be purely negative space
            _polys_n.pop_at(i)
            print("Removed n-polygon at pos ", i, ", new size ", _polys_n.size())
            _report_progress()
            # then, DON'T increment i, because the next element is now at position i
        else:
            i += 1


func _cut_next_level() -> bool:
    # Remove purely negative space
    # (loop is done this way to allow for concurrent modification)
    var i := 0
    while i < _polys_n.size():
        i += 1
    return false

# Helpers ==========================================================================================

func _report_progress():
    _progress_callback.call(1 - (_polys_n.size() / _original_n_size))


func _invert_bitmap(bitmap: BitMap) -> BitMap:
    var inverted := BitMap.new()
    var input_size := bitmap.get_size()
    inverted.create(input_size)
    for y in input_size.y:
        for x in input_size.x:
            inverted.set_bit(x, y, !bitmap.get_bit(x, y))
    return inverted


func _bitmap_to_polygons(bitmap: BitMap) -> Array[PackedVector2Array]:
    return bitmap.opaque_to_polygons(Rect2(Vector2(), bitmap.get_size()), _POLY_EPSILON)
