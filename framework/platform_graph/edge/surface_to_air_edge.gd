# Information for how to move from a surface to a position in the air.
extends Edge
class_name SurfaceToAirEdge

var start: PositionAlongSurface
var end: Vector2

func _init(start: PositionAlongSurface, end: Vector2) \
        .(_calculate_instructions(start, end)) -> void:
    self.start = start
    self.end = end

# TODO: Implement this

static func _calculate_instructions( \
        start: PositionAlongSurface, end: Vector2) -> MovementInstructions:
    return null
