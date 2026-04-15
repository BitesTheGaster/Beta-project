class_name CollisionRule
extends ValidationRule

@export var player_aabb_size: Vector3 = Vector3(0.8, 1.8, 0.8)

func check(action: Action, context: Dictionary) -> ValidationResult:
	if not action is PlaceBlockAction:
		return ValidationResult.ok()
	
	var place_action = action as PlaceBlockAction
	if place_action.block_id == 0:
		return ValidationResult.ok()
	
	var block_aabb = AABB(Vector3(place_action.position), Vector3.ONE)

	if context["local_player"] and \
			_get_player_aabb(context["local_player"].position).intersects(block_aabb):
		if context["sender_id"] == 1:
			return ValidationResult.invalid("collision_with_self")
		return ValidationResult.invalid("collision_with_player_1")
	
	for id in context["spawned_players"].keys():
		var remote_player: RemotePlayer = context["spawned_players"][id]
		if remote_player and \
				_get_player_aabb(remote_player.position).intersects(block_aabb):
			if context["sender_id"] == id:
				return ValidationResult.invalid("collision_with_self")
			return ValidationResult.invalid("collision_with_player_"+str(id))
	
	return ValidationResult.ok()


func _get_player_aabb(pos: Vector3) -> AABB:
	return AABB(
		pos-Vector3(0.4, 0.9, 0.4),
		Vector3(0.8, 1.8, 0.8)
	)
