class_name BlockActionSubmitter
extends Node


@export var player: Player


func submit(block_id: int) -> void:
	if not player.queue:
		return
	
	var hit = _get_pointed_voxel()
	if not hit:
		return
	
	var target_pos = hit.position if block_id == 0 else hit.previous_position
	
	var action = PlaceBlockAction.new()
	action.position = target_pos
	action.block_id = block_id
	action.sender_id = multiplayer.get_unique_id()
	
	player.queue.submit(
		action,
		Callable(self, "_on_block_action_success"),
		Callable(self, "_on_block_action_failure")
	)


func _on_block_action_success(a: PlaceBlockAction) -> void:
	pass


func _on_block_action_failure(reason: String, a: PlaceBlockAction) -> void:
	print("Block not placed at ", a.position,": ", reason)


func _get_pointed_voxel() -> VoxelRaycastResult:
	if not player.voxel_tool:
		return null
	
	var origin := player.camera_pivot_x.get_global_transform().origin
	var forward := -player.camera_pivot_x.get_global_transform().basis.z.normalized()
	return player.voxel_tool.raycast(origin, forward, 5)
