extends LoadingScreen


@onready var progress_bar: ProgressBar = $PanelContainer/RatioContainer/VBoxContainer/ProgressBar
@onready var loading_message: Label = $PanelContainer/RatioContainer/VBoxContainer/Message


func _on_progress_changed(current_progress: float):
    progress_bar.value = current_progress * 100


func _on_message_changed(message: String):
    loading_message.text = message


func _on_loading_done():
    progress_bar.value = 100
