extends PlayerParams
class_name TestPlayerParams

const JumpFromPlatformMovement := preload("res://framework/movement/models/jump_from_platform_movement.gd")
const FallFromAirMovement := preload("res://framework/movement/models/fall_from_air_movement.gd")
const TestPlayer := preload("res://framework/test/test_data/test_player.gd")

const PLAYER_RESOURCE_PATH := "res://framework/test/test_data/test_player.tscn"
const NAME := "test"
const CAN_GRAB_WALLS := true
const CAN_GRAB_CEILINGS := false
const CAN_GRAB_FLOORS := true
const COLLIDER_ROTATION := 0.0

func _init(global: Global).(NAME, PLAYER_RESOURCE_PATH, global) -> void:
    pass

func _create_action_handlers() -> Array:
    return [
        global.PLAYER_ACTIONS[AirDashAction.NAME],
        global.PLAYER_ACTIONS[AirDefaultAction.NAME],
        global.PLAYER_ACTIONS[AirJumpAction.NAME],
        global.PLAYER_ACTIONS[AllDefaultAction.NAME],
        global.PLAYER_ACTIONS[CapVelocityAction.NAME],
        global.PLAYER_ACTIONS[FloorDashAction.NAME],
        global.PLAYER_ACTIONS[FloorDefaultAction.NAME],
        global.PLAYER_ACTIONS[FloorFallThroughAction.NAME],
        global.PLAYER_ACTIONS[FloorJumpAction.NAME],
        global.PLAYER_ACTIONS[FloorWalkAction.NAME],
        global.PLAYER_ACTIONS[WallClimbAction.NAME],
        global.PLAYER_ACTIONS[WallDashAction.NAME],
        global.PLAYER_ACTIONS[WallDefaultAction.NAME],
        global.PLAYER_ACTIONS[WallFallAction.NAME],
        global.PLAYER_ACTIONS[WallJumpAction.NAME],
        global.PLAYER_ACTIONS[WallWalkAction.NAME],
    ]

# Array<Movement>
func _create_movement_types(movement_params: MovementParams) -> Array:
    return [
        JumpFromPlatformMovement.new(movement_params),
        FallFromAirMovement.new(movement_params),
    ]

func _create_movement_params() -> MovementParams:
    var movement_params := MovementParams.new()
    
    movement_params.can_grab_walls = CAN_GRAB_WALLS
    movement_params.can_grab_ceilings = CAN_GRAB_CEILINGS
    movement_params.can_grab_floors = CAN_GRAB_FLOORS
    
    var shape = RectangleShape2D.new()
    shape.extents = Vector2(10, 10)
    movement_params.collider_shape = shape
    movement_params.collider_rotation = COLLIDER_ROTATION
    
    movement_params.gravity_fast_fall = Geometry.GRAVITY
    movement_params.slow_ascent_gravity_multiplier = 0.18
    movement_params.ascent_double_jump_gravity_multiplier = 0.08
    
    movement_params.jump_boost = -1000.0
    movement_params.in_air_horizontal_acceleration = 1500.0
    movement_params.max_jump_chain = 2
    movement_params.wall_jump_horizontal_multiplier = 0.5
    
    movement_params.walk_acceleration = 350.0
    movement_params.climb_up_speed = -350.0
    movement_params.climb_down_speed = 150.0
    
    movement_params.max_horizontal_speed_default = 400.0
    movement_params.current_max_horizontal_speed = movement_params.max_horizontal_speed_default
    movement_params.min_horizontal_speed = 5.0
    movement_params.max_vertical_speed = 4000.0
    movement_params.min_vertical_speed = 0.0
    
    movement_params.fall_through_floor_velocity_boost = 100.0
    
    movement_params.min_speed_to_maintain_vertical_collision = 15.0
    movement_params.min_speed_to_maintain_horizontal_collision = 60.0
    
    movement_params.dash_speed_multiplier = 4.0
    movement_params.dash_vertical_boost = -400.0
    movement_params.dash_duration = 0.3
    movement_params.dash_fade_duration = 0.1
    movement_params.dash_cooldown = 1.0
    
    movement_params.friction_multiplier = 0.01
    
    return movement_params
