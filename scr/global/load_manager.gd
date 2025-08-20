extends Node


enum LoadingState { IDLE, PREPARING_LOAD_SCREEN, LOADING_SCENE_FILE, WAITING_FOR_SCENE_READY }
class WaitingNodeInfo:
    var weight := 1.0
    var progress := 0.0


# Signals
signal message_changed(message: String)
signal progress_changed(current_progress: float)
signal loading_done


# Internal state (reset after every load)
var loading_state: LoadingState = LoadingState.IDLE
var load_screen: LoadingScreen
var scene_path: String
var loaded_scene: PackedScene
var wait_for_ready: bool
var file_load_progress: Array[float] = []
var scene_process_mode: int = -1
var nodes_waiting: Dictionary[Node, WaitingNodeInfo] = {}
var total_ready_weight: float = 0.0
var total_ready_progress: float = 0.0
var mutex: Mutex = Mutex.new()

# MAIN FUNCTIONS ===================================================================================

@warning_ignore("shadowed_variable")
func load_scene(scene_path: String, load_screen_scene: PackedScene, wait_for_ready: bool = false, use_sub_threads: bool = false):
    # Current state: loading the load screen (lol)
    loading_state = LoadingState.PREPARING_LOAD_SCREEN
    # Other internal state
    self.scene_path = scene_path
    self.wait_for_ready = wait_for_ready
    # Set up load screen
    load_screen = load_screen_scene.instantiate() # (this should be fast, hopefully)
    message_changed.connect(load_screen._on_message_changed)
    progress_changed.connect(load_screen._on_progress_changed)
    loading_done.connect(load_screen._on_loading_done)
    # Start loading scene file
    loading_state = LoadingState.LOADING_SCENE_FILE
    var error := ResourceLoader.load_threaded_request(scene_path, "PackedScene", use_sub_threads)
    if error:
        fail("Loading scene '%s' failed" % scene_path)
    else:
        get_tree().current_scene.process_mode = Node.PROCESS_MODE_DISABLED
        add_child(load_screen)
        process_mode = Node.PROCESS_MODE_ALWAYS


func get_loading_state() -> LoadingState:
    mutex.lock()
    var state := loading_state
    mutex.unlock()
    return state


func set_message(message: String):
    mutex.lock()
    message_changed.emit(message)
    mutex.unlock()


func register_node_waiting(node: Node, weight: float = 1.0):
    mutex.lock()
    if loading_state != LoadingState.WAITING_FOR_SCENE_READY:
        var info := WaitingNodeInfo.new()
        info.weight = weight
        nodes_waiting[node] = info
        total_ready_weight += weight
    mutex.unlock()


func report_node_progress(node: Node, progress: float):
    mutex.lock()
    if loading_state != LoadingState.WAITING_FOR_SCENE_READY and nodes_waiting.has(node):
        var dp := progress - nodes_waiting[node].progress
        total_ready_progress += dp * nodes_waiting[node].weight
        nodes_waiting[node].progress = progress
    mutex.unlock()


func report_node_done(node: Node):
    mutex.lock()
    if loading_state != LoadingState.WAITING_FOR_SCENE_READY and nodes_waiting.has(node):
        var dp := 1.0 - nodes_waiting[node].progress
        total_ready_progress += dp * nodes_waiting[node].weight
        nodes_waiting.erase(node)
    mutex.unlock()

# ==================================================================================================

func _ready() -> void:
    # Don't process this node until we're actually loading something
    process_mode = Node.PROCESS_MODE_DISABLED


func _process(_delta: float) -> void:
    match loading_state:
        LoadingState.LOADING_SCENE_FILE:
            process_loading_file()
        LoadingState.WAITING_FOR_SCENE_READY:
            process_waiting_ready()


func threadsafe_emit_progress(progress: float):
    mutex.lock()
    progress_changed.emit(progress)
    mutex.unlock()


func process_loading_file():
    var load_status := ResourceLoader.load_threaded_get_status(scene_path, file_load_progress)
    match load_status:
        ResourceLoader.THREAD_LOAD_INVALID_RESOURCE:
            # This is returned when the requested path isn't being loaded, but
            # unfortunately it will return this just after the load starts too
            return

        ResourceLoader.THREAD_LOAD_IN_PROGRESS:
            # Scene in the process of being loaded
            progress_changed.emit(file_load_progress[0])

        ResourceLoader.THREAD_LOAD_FAILED:
            # Scene failed to load
            fail("Loading scene '%s' failed, %s" % [scene_path, load_status])

        ResourceLoader.THREAD_LOAD_LOADED:
            # Scene is done loading
            loaded_scene = ResourceLoader.load_threaded_get(scene_path)
            threadsafe_emit_progress(1.0)
            get_tree().change_scene_to_packed(loaded_scene)
            if wait_for_ready:
                threadsafe_emit_progress(0.0)
                # Start waiting for the new scene to be ready
                loading_state = LoadingState.WAITING_FOR_SCENE_READY
            else:
                done()



func process_waiting_ready():
    var cur_scene := get_tree().current_scene
    if not nodes_waiting.is_empty():
        # Freeze the scene, if it's valid and not disabled already
        if is_instance_valid(cur_scene) and cur_scene.process_mode != Node.PROCESS_MODE_DISABLED:
            scene_process_mode = cur_scene.process_mode
            cur_scene.process_mode = Node.PROCESS_MODE_DISABLED
        # Report progress
        threadsafe_emit_progress(total_ready_progress / total_ready_weight)
    else:
        threadsafe_emit_progress(1.0)
        # Return the scene to whatever process mode it's supposed to have
        if is_instance_valid(cur_scene) and scene_process_mode != -1:
            cur_scene.process_mode = scene_process_mode as ProcessMode
        done()


func fail(error_message: String):
    push_error(error_message)
    cleanup()


func done():
    loading_done.emit()
    cleanup()


func cleanup():
    if is_instance_valid(load_screen):
        load_screen.queue_free()
    process_mode = Node.PROCESS_MODE_DISABLED
    # Reset state
    loading_state = LoadingState.IDLE
    load_screen = null
    scene_path = ""
    loaded_scene = null
    file_load_progress = []
    scene_process_mode = -1
    nodes_waiting = {}
