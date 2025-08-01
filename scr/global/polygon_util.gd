extends Node


class SplitResult:
    var vertical: bool
    var side_a: Array[PackedVector2Array]
    var side_b: Array[PackedVector2Array]


## Returns true if the first argument [param inner] is completely enclosed within the
## second argument [param outer].
func completely_enclosed(inner: PackedVector2Array, outer: PackedVector2Array) -> bool:
    var clip_result := Geometry2D.clip_polygons(outer, inner)
    var enclosed := false
    for p in clip_result:
        if Geometry2D.is_polygon_clockwise(p):
            enclosed = true
            break
    return enclosed


## Compute the area of a polygon. Uses the algorithm found here:
## [url=https://web.archive.org/web/20100405070507/http://valis.cs.uiuc.edu/~sariel/research/CG/compgeom/msg00831.html]Wayback Machine[/url]
func area(polygon: PackedVector2Array) -> float:
    var twice_area := 0.0
    for i in polygon.size():
        var j := (i + 1) % polygon.size()
        twice_area += polygon[i].x * polygon[j].y
        twice_area -= polygon[i].y * polygon[j].x
    return twice_area * 0.5


func extents(polygon: PackedVector2Array) -> Rect2:
    var left := INF
    var right := -INF
    var top := INF
    var bottom := -INF
    for v in polygon:
        if v.x > right: right = v.x
        if v.x < left: left = v.x
        if v.y > bottom: bottom = v.y
        if v.y < top: top = v.y
    return Rect2(top, left, bottom - top, right - left)


func rect_to_polygon(rect: Rect2) -> PackedVector2Array:
    return [
        rect.position,
        Vector2(rect.position.x, rect.end.y),
        rect.end,
        Vector2(rect.end.x, rect.position.y)
    ]


func split(polygon: PackedVector2Array, split_point: Vector2) -> SplitResult:
    var bounds := extents(polygon)
    var vertical := bounds.size.x > bounds.size.y
    if vertical:
        bounds.end.x = split_point.x
        bounds.grow_individual(1, 1, 0, 1)
    else:
        bounds.end.y = split_point.y
        bounds.grow_individual(1, 1, 1, 0)
    var result := SplitResult.new()
    var mask := rect_to_polygon(bounds)
    result.side_a = Geometry2D.intersect_polygons(polygon, mask)
    result.side_b = Geometry2D.clip_polygons(polygon, mask)
    result.vertical = vertical
    return result
