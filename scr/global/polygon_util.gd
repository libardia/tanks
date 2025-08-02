class_name PolygonUtil


class SplitResult:
    var vertical: bool
    var side_a: Array[PackedVector2Array]
    var side_b: Array[PackedVector2Array]


## Returns true if the first argument [param inner] is completely enclosed within the
## second argument [param outer].
static func is_completely_enclosed(inner: PackedVector2Array, outer: PackedVector2Array) -> bool:
    var clip_result := Geometry2D.clip_polygons(outer, inner)
    var enclosed := false
    for p in clip_result:
        if Geometry2D.is_polygon_clockwise(p):
            enclosed = true
            break
    return enclosed


## Compute the area of a polygon. Uses the algorithm found here:
## [url=https://web.archive.org/web/20100405070507/http://valis.cs.uiuc.edu/~sariel/research/CG/compgeom/msg00831.html]Wayback Machine[/url]
static func area(polygon: PackedVector2Array) -> float:
    var twice_area := 0.0
    for i in polygon.size():
        var j := (i + 1) % polygon.size()
        twice_area += polygon[i].x * polygon[j].y
        twice_area -= polygon[i].y * polygon[j].x
    return absf(twice_area * 0.5)


static func extents(polygon: PackedVector2Array) -> Rect2:
    var right: float
    var left: float
    var bottom: float
    var top: float
    for i in polygon.size():
        var v := polygon[i]
        if i == 0:
            right = v.x
            left = v.x
            bottom = v.y
            top = v.y
        else:
            if v.x > right: right = v.x
            elif v.x < left: left = v.x
            if v.y > bottom: bottom = v.y
            elif v.y < top: top = v.y
    return Rect2(left, top, right - left, bottom - top)


static func rect_to_polygon(rect: Rect2) -> PackedVector2Array:
    return [
        rect.position,
        Vector2(rect.position.x, rect.end.y),
        rect.end,
        Vector2(rect.end.x, rect.position.y)
    ]


static func split(polygon: PackedVector2Array, split_point: Vector2) -> SplitResult:
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


static func offset_in_place(polygon: PackedVector2Array, translation: Vector2):
    for i in polygon.size():
        polygon[i] += translation


static func offset(polygon: PackedVector2Array, translation: Vector2) -> PackedVector2Array:
    var new_poly := PackedVector2Array()
    new_poly.resize(polygon.size())
    for i in new_poly.size():
        new_poly[i] = polygon[i] + translation
    return new_poly


static func clip_handle_holes(against: PackedVector2Array, clip: PackedVector2Array) -> Array[PackedVector2Array]:
    var results := Geometry2D.clip_polygons(against, clip)
    var enclosed := false
    for p in results:
        if Geometry2D.is_polygon_clockwise(p):
            enclosed = true
            break
    if enclosed:
        # clear results
        results = []
        var split_point := extents(clip).get_center()
        var split_result := split(against, split_point)
        for ps in [split_result.side_a, split_result.side_b]:
            for p in ps:
                results.append_array(Geometry2D.clip_polygons(p, clip))
    return results


static func generate_circle(radius: float, points: int) -> PackedVector2Array:
    var circle := PackedVector2Array()
    circle.resize(points)
    var theta := (2 * PI) / points
    for i in circle.size():
        circle[i] = Vector2(sin(i * theta), cos(i * theta)) * radius
    return circle
