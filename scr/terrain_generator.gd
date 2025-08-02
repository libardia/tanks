class_name TerrainGenerator

const POLY_EPSILON := 0.0
var gen_thread := Thread.new()

signal progress(prog: float)
signal done(polys: Array[PackedVector2Array])

# State ============================================================================================

var source_image: Image
var transparency_threshold: float
var chunk_size: int
var chunk_width: int
var chunk_height: int
var total_chunks: int
var terrain_bitmap: BitMap = BitMap.new()
var chunks_done: int
var chunks_done_mutex: Mutex = Mutex.new()

# Entry ============================================================================================

@warning_ignore("shadowed_variable")
func begin_generate(source_image: Image, transparency_threshold: float, chunk_size: int):
    self.source_image = source_image
    self.transparency_threshold = transparency_threshold
    self.chunk_size = chunk_size
    chunk_width = ceili(source_image.get_width() / float(chunk_size))
    chunk_height = ceili(source_image.get_height() / float(chunk_size))
    total_chunks = chunk_width * chunk_height
    gen_thread.start(generate)

# Main generate function ===========================================================================

func generate():
    progress.emit(0.0)

    terrain_bitmap.create_from_image_alpha(source_image, transparency_threshold)

    var chunk_threads: Array[Thread] = []
    for cy in chunk_height:
        for cx in chunk_width:
            var chunk := Rect2i(cx * chunk_size, cy * chunk_size, chunk_size, chunk_size)
            var t := Thread.new()
            t.start(single_chunk.bind(chunk, 0))
            chunk_threads.append(t)

    var results: Array[PackedVector2Array] = []
    for thread in chunk_threads:
        results.append_array(thread.wait_to_finish())

    progress.emit(1.0)
    done.emit(results)


func single_chunk(chunk: Rect2i, depth: int) -> Array[PackedVector2Array]:
    var polys := terrain_bitmap.opaque_to_polygons(chunk, 0)
    for p in polys:
        PolygonUtil.offset(p, chunk.position)
    for y in chunk.size.y:
        var ty = y + chunk.position.y
        if ty >= terrain_bitmap.get_size().y:
            continue
        for x in chunk.size.x:
            var tx = x + chunk.position.x
            if tx >= terrain_bitmap.get_size().x:
                continue
            if not terrain_bitmap.get_bit(tx, ty):
                var pf := Vector2(tx + 0.5, ty + 0.5)
                var pi := Vector2i(tx, ty)
                for poly in polys:
                    if Geometry2D.is_point_in_polygon(pf, poly):
                        var new_polys: Array[PackedVector2Array] = []
                        for r in split_rect(chunk, pi):
                            new_polys.append_array(single_chunk(r, depth + 1))
                        if depth == 0:
                            chunk_done()
                        return new_polys
    if depth == 0:
        chunk_done()
    return polys

# Helpers ==========================================================================================

func chunk_done():
    chunks_done_mutex.lock()
    chunks_done += 1
    progress.emit(chunks_done / float(total_chunks))
    chunks_done_mutex.unlock()



func split_rect(rect: Rect2i, point: Vector2i) -> Array[Rect2i]:
    var r1 := Rect2i(rect)
    var r2 := Rect2i(rect)
    if rect.size.x > rect.size.y:
        r1.end = Vector2i(point.x, r1.end.y)
        var r2end = r2.end
        r2.position = Vector2i(point.x, r2.position.y)
        r2.end = r2end
    else:
        r1.end = Vector2i(r1.end.x, point.y)
        var r2end = r2.end
        r2.position = Vector2i(r2.position.x, point.y)
        r2.end = r2end
    return [r1, r2]
