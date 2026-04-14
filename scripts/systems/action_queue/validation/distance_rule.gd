class_name DistanceRule
extends ValidationRule


@export var max_distance: float = 5.0


func check(action: Action, context: Dictionary) -> ValidationResult:
	var sender_pos: Vector3 = context.get("sender_position", Vector3.ZERO)
	var target_vec = Vector3(action.get("position"))
	
	if sender_pos.distance_to(target_vec) > max_distance:
		return ValidationResult.invalid("too_far")
	return ValidationResult.ok()
