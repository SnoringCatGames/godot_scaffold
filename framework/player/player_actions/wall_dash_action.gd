extends PlayerAction
class_name WallDashAction

const NAME := 'WallDashAction'
const TYPE := PlayerActionType.WALL
const PRIORITY := 150

func _init().(NAME, TYPE, PRIORITY) -> void:
    pass

func process(player: Player) -> bool:
    if player.actions.start_dash:
        player.start_dash(-player.surface_state.toward_wall_sign)
        return true
    else:
        return false
