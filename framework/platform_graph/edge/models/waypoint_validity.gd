class_name WaypointValidity

enum {
    WAYPOINT_VALID,
    FAKE,
    TOO_HIGH,
    OUT_OF_REACH_FROM_ORIGIN,
    OUT_OF_REACH_FROM_ADDITIONAL_HIGH_WAYPOINT,
    THIS_WAYPOINT_OUT_OF_REACH_FROM_PREVIOUS_WAYPOINT,
    TRYING_TO_PASS_OVER_WALL_WHILE_DESCENDING,
    TRYING_TO_PASS_UNDER_WALL_WHILE_ASCENDING,
    NEXT_WAYPOINT_OUT_OF_REACH_FROM_THIS_WAYPOINT,
    NO_VALID_VELOCITY_FROM_ORIGIN,
    NO_VALID_VELOCITY_FOR_NEXT_STEP,
    UNKNOWN,
}

static func get_type_string(validity: int) -> String:
    match validity:
        WAYPOINT_VALID:
            return "WAYPOINT_VALID"
        FAKE:
            return "FAKE"
        TOO_HIGH:
            return "TOO_HIGH"
        OUT_OF_REACH_FROM_ORIGIN:
            return "OUT_OF_REACH_FROM_ORIGIN"
        OUT_OF_REACH_FROM_ADDITIONAL_HIGH_WAYPOINT:
            return "OUT_OF_REACH_FROM_ADDITIONAL_HIGH_WAYPOINT"
        THIS_WAYPOINT_OUT_OF_REACH_FROM_PREVIOUS_WAYPOINT:
            return "THIS_WAYPOINT_OUT_OF_REACH_FROM_PREVIOUS_WAYPOINT"
        TRYING_TO_PASS_OVER_WALL_WHILE_DESCENDING:
            return "TRYING_TO_PASS_OVER_WALL_WHILE_DESCENDING"
        TRYING_TO_PASS_UNDER_WALL_WHILE_ASCENDING:
            return "TRYING_TO_PASS_UNDER_WALL_WHILE_ASCENDING"
        NEXT_WAYPOINT_OUT_OF_REACH_FROM_THIS_WAYPOINT:
            return "NEXT_WAYPOINT_OUT_OF_REACH_FROM_THIS_WAYPOINT"
        NO_VALID_VELOCITY_FROM_ORIGIN:
            return "NO_VALID_VELOCITY_FROM_ORIGIN"
        NO_VALID_VELOCITY_FOR_NEXT_STEP:
            return "NO_VALID_VELOCITY_FOR_NEXT_STEP"
        UNKNOWN:
            return "UNKNOWN"
        _:
            Utils.error("Invalid WaypointValidity: %s" % validity)
            return "UNKNOWN"
