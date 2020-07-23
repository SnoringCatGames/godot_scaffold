# Parameters that are used for calculating edge instructions.
extends Reference
class_name EdgeStepCalcParams

# The start position of this local branch of movement.
var start_waypoint: Waypoint

# The end position of this local branch of movement.
var end_waypoint: Waypoint

# The single vertical step for this overall jump movement.
var vertical_step: VerticalEdgeStep

func _init( \
        start_waypoint: Waypoint, \
        end_waypoint: Waypoint, \
        vertical_step: VerticalEdgeStep) -> void:
    self.start_waypoint = start_waypoint
    self.end_waypoint = end_waypoint
    self.vertical_step = vertical_step
