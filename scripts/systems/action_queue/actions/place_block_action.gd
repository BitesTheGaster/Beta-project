class_name PlaceBlockAction
extends Action


@export var max_distance: float = 5.0
@export var player_aabb_size: Vector3 = Vector3(0.8, 1.8, 0.8)

var position: Vector3i = Vector3i.ZERO
var block_id: int = 0


func to_dict() -> Dictionary:
	var dict = super.to_dict()
	dict["position"] = position
	dict["block_id"] = block_id
	return dict


static func from_dict(data: Dictionary) -> PlaceBlockAction:
	var action = PlaceBlockAction.new()
	
	action.sequence_id = data.get("seq", 0)
	action.timestamp = data.get("ts", 0.0)
	action.sender_id = data.get("sender", 0)
	
	action.position = data.get("position", Vector3.ZERO)
	action.block_id = data.get("block_id", 0)
	
	return action


func validate(context: Dictionary) -> ValidationResult:
	# Distance check
	var sender_pos: Vector3 = context.get("sender_position", Vector3.ZERO)
	var target_vec = position
	
	if sender_pos.distance_to(target_vec) > max_distance:
		return ValidationResult.invalid("too_far")
	
	# Collision check
	if block_id == 0:
		return ValidationResult.ok()
	
	var block_aabb = AABB(Vector3(position), Vector3.ONE)

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


func execute(world: GameWorld) -> void:
	if world.block_manager:
		world.block_manager.set_block.rpc(block_id, position)


func _get_player_aabb(pos: Vector3) -> AABB:
	return AABB(
		pos-player_aabb_size/2,
		player_aabb_size
	)
