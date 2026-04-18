class_name SyncPositionAction
extends Action


var position: Vector3
var rotation: Vector3
var velocity: Vector3


func to_dict() -> Dictionary:
	var dict = super.to_dict()
	
	dict["position"] = position
	dict["rotation"] = rotation
	dict["velocity"] = velocity
	
	return dict


static func from_dict(data: Dictionary) -> SyncPositionAction:
	var action = SyncPositionAction.new()
	
	action.sequence_id = data.get("seq", 0)
	action.timestamp = data.get("ts", 0.0)
	action.sender_id = data.get("sender", 0)
	
	action.position = data.get("position", Vector3.ZERO)
	action.rotation = data.get("rotation", Vector3.ZERO)
	action.velocity = data.get("velocity", Vector3.ZERO)
	
	return action


func validate(context: Dictionary) -> ValidationResult:
	
	return ValidationResult.ok()


func execute(world: GameWorld) -> void:
	world.players_container.sync_player_position.rpc(sender_id, position, rotation, velocity)
