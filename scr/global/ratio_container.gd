@tool
class_name RatioContainer
extends Container

enum Alignment { BEGIN, CENTER, END }

@export_range(0, 1, 0.001, "or_greater") var vertical_ratio: float = 1.0:
    get:
        return vertical_ratio
    set(value):
        vertical_ratio = value
        queue_sort()
@export var vertical_alignment: Alignment:
    get:
        return vertical_alignment
    set(value):
        vertical_alignment = value
        queue_sort()
@export_range(0, 1, 0.001, "or_greater") var horizontal_ratio: float = 1.0:
    get:
        return horizontal_ratio
    set(value):
        horizontal_ratio = value
        queue_sort()
@export var horizontal_alignment: Alignment:
    get:
        return horizontal_alignment
    set(value):
        horizontal_alignment = value
        queue_sort()


func _notification(what: int) -> void:
    if what == NOTIFICATION_SORT_CHILDREN:
        for child in get_children():
            if child is Control:
                var c := child as Control
                var final_rect := Rect2(Vector2.ZERO, size)
                var c_min := c.get_combined_minimum_size()
                #final_rect.size.x = max(size.x * horizontal_ratio, c_min.x)
                #final_rect.size.y = max(size.y * vertical_ratio, c_min.y)
                final_rect.size.x = size.x * horizontal_ratio
                final_rect.size.y = size.y * vertical_ratio
                match horizontal_alignment:
                    Alignment.CENTER:
                        final_rect.position.x = (size.x - final_rect.size.x) / 2
                    Alignment.END:
                        final_rect.position.x = size.x - final_rect.size.x
                match vertical_alignment:
                    Alignment.CENTER:
                        final_rect.position.y = (size.y - final_rect.size.y) / 2
                    Alignment.END:
                        final_rect.position.y = size.y - final_rect.size.y
                fit_child_in_rect(c, final_rect)
