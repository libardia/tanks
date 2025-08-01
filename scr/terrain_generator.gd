class_name TerrainGenerator

const POLY_EPSILON := 0.0
var gen_thread := Thread.new()

# State ============================================================================================

var source_image: Image
var transparency_threshold: float
var chunk_size: int
var chunk_width: int
var chunk_height: int
var total_chunks: int
var progress_callback: Callable
var done_callback: Callable
var ground_bitmap: BitMap = BitMap.new()
var polys: Array[PackedVector2Array]

# Entry ============================================================================================

@warning_ignore("shadowed_variable")
func begin_generate(source_image: Image, transparency_threshold: float, chunk_size: int, progress_callback: Callable, done_callback: Callable):
    self.source_image = source_image
    self.transparency_threshold = transparency_threshold
    self.chunk_size = chunk_size
    chunk_width = ceili(source_image.get_width() / float(chunk_size))
    chunk_height = ceili(source_image.get_height() / float(chunk_size))
    total_chunks = chunk_width * chunk_height
    self.progress_callback = progress_callback
    self.done_callback = done_callback
    gen_thread.start(generate)

# Main generate function ===========================================================================

func generate():
    progress_callback.call(0.0)

    progress_callback.call(1.0)
