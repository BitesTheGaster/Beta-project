class_name PlaceBlockAction
extends Action


var position: Vector3i = Vector3i.ZERO  # Где поставить
var block_id: int = 0                    # Какой блок


func to_dict() -> Dictionary:
	var dict = super.to_dict()
	dict["pos_x"] = position.x
	dict["pos_y"] = position.y
	dict["pos_z"] = position.z
	dict["block_id"] = block_id
	return dict


static func from_dict(data: Dictionary) -> PlaceBlockAction:
	var action = PlaceBlockAction.new()
	action.sequence_id = data.get("seq", 0)
	action.timestamp = data.get("ts", 0.0)
	action.sender_id = data.get("sender", 0)
	action.position = Vector3i(
		data.get("pos_x", 0),
		data.get("pos_y", 0),
		data.get("pos_z", 0)
	)
	action.block_id = data.get("block_id", 0)
	return action


func validate(context: Dictionary) -> ValidationResult:
	return ValidationResult.ok()


func execute(world: GameWorld) -> void:
	if world.block_manager:
		world.block_manager.set_block.rpc(block_id, position)
