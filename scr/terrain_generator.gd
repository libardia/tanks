class_name TerrainGenerator

const POLY_EPSILON := 0.0
var gen_thread := Thread.new()

# State ============================================================================================

var source_image: Image
var transparency_threshold: float
var progress_callback: Callable
var done_callback: Callable
var ground_bitmap: BitMap = BitMap.new()
var polys: Array[PackedVector2Array]

# Entry ============================================================================================

@warning_ignore("shadowed_variable")
func begin_generate(source_image: Image, transparency_threshold: float, progress_callback: Callable, done_callback: Callable):
    self.source_image = source_image
    self.transparency_threshold = transparency_threshold
    self.progress_callback = progress_callback
    self.done_callback = done_callback
    gen_thread.start(generate)

# Main generate function ===========================================================================

func generate():
    progress_callback.call(0.0)

    progress_callback.call(1.0)
