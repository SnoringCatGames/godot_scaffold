extends Reference
class_name PlayerAction

var name: String
# PlayerActionType
var type: int
var priority: int

func _init(name: String, type: int, priority: int) -> void:
    self.name = name
    self.type = type
    self.priority = priority

# TODO: Add type back in.
func process(player) -> bool:
    Utils.error("abstract PlayerAction.process is not implemented")
    return false
