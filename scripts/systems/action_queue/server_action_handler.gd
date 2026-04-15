class_name ServerActionHandler
extends Node
## Handle actions sent to server


@export var validation_rules: Array[ValidationRule] = []

@onready var block_manager: BlockManager = %BlockManager
@onready var queue_manager: ActionQueue = %ActionQueue
@onready var world: GameWorld = get_parent()


# Receives, checks and executes actions in world
@rpc("any_peer", "call_local", "reliable", 1)
func rpc_receive_action(data: Dictionary) -> void:
	var type_str = data.get("type", "")
	var action = _deserialize_action(type_str, data)
	if not action:
		_send_result.rpc_id(multiplayer.get_remote_sender_id(), data.get("seq", 0), false, "unknown_action")
		return

	var context = _build_validation_context(multiplayer.get_remote_sender_id(), action)
	var result = _validate(action, context)

	_send_result.rpc_id(multiplayer.get_remote_sender_id(), action.sequence_id, result.is_valid, result.reason)

	if result.is_valid:
		action.execute(world)
		# _sync_block_to_all.rpc(action.position, action.block_id)


func _deserialize_action(type_str: String, data: Dictionary) -> Action:
	if type_str == "place_block_action.gd":
		return PlaceBlockAction.from_dict(data)
	return null


func _build_validation_context(sender_id: int, action: Action) -> Dictionary:
	var context: Dictionary = {
			"sender_id": sender_id,
				}
	
	if action is PlaceBlockAction:
		context["spawned_players"] = world.spawned_players
		context["local_player"] = world.local_player
		context["sender_position"] = _get_player_pos(sender_id)
		context["target_position"] = action.get("position")
	
	return context


func _validate(action: Action, context: Dictionary) -> ValidationResult:
	for rule in validation_rules:
		var res = rule.check(action, context)
		if not res.is_valid:
			return res
	return ValidationResult.ok()


func _get_player_pos(id: int) -> Vector3:
	if id == multiplayer.get_unique_id():
		return world.local_player.position
	return world.spawned_players[id].position


# Send reply to clients
@rpc("authority", "call_local", "reliable", 1)
func _send_result(seq_id: int, success: bool, reason: String) -> void:
	if success:
		queue_manager.confirm(seq_id)
	else:
		queue_manager.reject(seq_id, reason)
