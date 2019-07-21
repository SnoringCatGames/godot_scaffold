extends Reference
class_name Navigator

var player # TODO: Add type back
var graph: PlatformGraph
var surface_state: PlayerSurfaceState
var surface_parser: SurfaceParser
var instructions_action_source: InstructionsActionSource

var is_currently_navigating := false
var reached_destination := false
var current_path: PlatformGraphPath
var current_edge: Edge
var current_edge_index := -1
var current_edge_playback: InstructionsPlayback

var just_interrupted_navigation := false
var just_reached_end_of_edge := false
var just_reached_intra_surface_destination := false
var just_landed_on_expected_surface := false
var just_reached_in_air_destination := false

func _init(player, graph: PlatformGraph) -> void:
    self.player = player
    self.graph = graph
    self.surface_state = player.surface_state
    self.surface_parser = graph.surface_parser
    self.instructions_action_source = InstructionsActionSource.new(player)

# Starts a new navigation to the given destination.
func start_new_navigation(target: Vector2) -> bool:
    # FIXME: B: Remove
    assert(surface_state.is_grabbing_a_surface)
    
    reset()
    
    var origin := surface_state.player_center_position_along_surface
    var destination := SurfaceParser.find_closest_position_on_a_surface(target, player)
    # FIXME: LEFT OFF HERE: -----------A
    # - Add support for an in-air origin and destination.
    # - Implement two new Edge sub-classes for these.
    var path := graph.find_path(origin, destination)
    
    if path == null:
        # Destination cannot be reached from origin.
        return false
    else:
        # Destination can be reached from origin.
        current_path = path
        current_edge = current_path.edges[0]
        current_edge_index = 0
        is_currently_navigating = true
        reached_destination = false
        current_edge_playback = \
                instructions_action_source.start_instructions(current_edge.instructions)
        return true

func _set_reached_destination() -> void:
    # FIXME: Assert that we are close enough to the destination position.
#    assert()
    
    reached_destination = true
    is_currently_navigating = false
    current_edge = null
    current_edge_index = -1
    current_edge_playback = null
    instructions_action_source.cancel_all_playback()

func reset() -> void:
    current_path = null
    current_edge = null
    current_edge_index = -1
    is_currently_navigating = false
    reached_destination = false
    current_edge_playback = null
    instructions_action_source.cancel_all_playback()
    just_interrupted_navigation = false
    just_reached_end_of_edge = false
    just_reached_intra_surface_destination = false
    just_landed_on_expected_surface = false
    just_reached_in_air_destination = false

# Updates player-graph state in response to the given new PlayerSurfaceState.
func update() -> void:
    if !is_currently_navigating:
        return
    
    _update_edge_navigation_state()
    
    # FIXME: LEFT OFF HERE: ---------------------A
    # - Address the other edge-type cases in start_new_navigation above (don't just require start
    #   and end on surfaces).
    # - Implement the instruction-calculations for the other three edge sub-classes.
    
    if just_interrupted_navigation:
        print("Edge movement interrupted")
        # FIXME: Add back in at some point...
#        start_new_navigation(current_path.destination)
    elif just_reached_intra_surface_destination:
        print("Reached end of intra-surface edge")
    elif just_landed_on_expected_surface:
        print("Reached end of inter-surface or air-to-surface edge")
    elif just_reached_in_air_destination:
        print("Reached end of surface-to-air or air-to-air edge")
    elif surface_state.is_grabbing_a_surface:
#        print("Moving along intra-surface edge")
        
        # The intra-surface-edge movement instruction set should continue executing.
        pass
    else: # Moving through the air.
#        print("Moving along inter-surface edge")
        
        # FIXME: Detect when position is too far from expected. Then maybe auto-correct it?
        
        # The inter-surface-edge movement instruction set should continue executing.
        pass
    
    if just_reached_end_of_edge:
        # FIXME: Assert that we are close enough to the destination position.
        # assert()
        
        # Cancel the current intra-surface instructions (in case it didn't clear itself).
        instructions_action_source.cancel_playback(current_edge_playback)
        
        # Check for the next edge to navigate.
        var was_last_edge := current_path.edges.size() == current_edge_index + 1
        if was_last_edge:
            _set_reached_destination()
        else:
            current_edge_index += 1
            current_edge = current_path.edges[current_edge_index]
            current_edge_playback = \
                    instructions_action_source.start_instructions(current_edge.instructions)

func _update_edge_navigation_state() -> void:
    var is_grabbed_surface_expected: bool = \
            surface_state.grabbed_surface == current_edge.end.surface
    var is_moving_along_intra_surface_edge := \
            surface_state.is_grabbing_a_surface and is_grabbed_surface_expected
    # FIXME: E: Add support for walking into a wall and climbing up it.
    var just_collided_unexpectedly: bool = surface_state.just_left_air and \
            !is_grabbed_surface_expected and player.surface_state.collision_count > 0
    var just_entered_air_unexpectedly := \
            surface_state.just_entered_air and !just_reached_intra_surface_destination
    just_landed_on_expected_surface = surface_state.just_left_air and \
            surface_state.grabbed_surface == current_edge.end.surface
    just_interrupted_navigation = just_collided_unexpectedly or just_entered_air_unexpectedly
    
    if is_moving_along_intra_surface_edge:
        var target_point: Vector2 = current_edge.end.target_point
        var was_less_than_end: bool
        var is_less_than_end: bool
        if surface_state.is_grabbing_wall:
            was_less_than_end = surface_state.previous_center_position.y < target_point.y
            is_less_than_end = surface_state.center_position.y < target_point.y
        else:
            was_less_than_end = surface_state.previous_center_position.x < target_point.x
            is_less_than_end = surface_state.center_position.x < target_point.x
        
        just_reached_intra_surface_destination = was_less_than_end != is_less_than_end
    else:
        just_reached_intra_surface_destination = false
    
    var is_moving_to_expected_in_air_destination: bool = \
            surface_state.is_in_air and \
            (current_edge is SurfaceToAirEdge or \
            current_edge is AirToAirEdge)
    
    if is_moving_to_expected_in_air_destination:
        # FIXME: LEFT OFF HERE: --------------------A
        current_edge_playback.is_finished
        pass
    else:
        just_reached_in_air_destination = false
    
    just_reached_end_of_edge = \
            just_reached_intra_surface_destination or \
            just_landed_on_expected_surface or \
            just_reached_in_air_destination
