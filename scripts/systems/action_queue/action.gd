@abstract
class_name Action
extends RefCounted
## Base class for every network action


var sequence_id: int = 0
var timestamp: float = 0.0
var sender_id: int = 0


@abstract
func validate(context: Dictionary) -> ValidationResult


@abstract
func execute(world: GameWorld) -> void


func to_dict() -> Dictionary:
	return {
		"type": _get_action_type(),
		"seq": sequence_id,
		"ts": timestamp,
		"sender": sender_id
	}


func _get_action_type() -> String:
	return get_script().get_path().get_file()
