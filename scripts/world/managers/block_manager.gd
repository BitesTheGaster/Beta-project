class_name BlockManager
extends Node
## Controls block placing


@export var voxel_terrain: VoxelTerrain

var changed_blocks: Dictionary[Vector3i, int] = {}
var blocks_queue: Dictionary[Vector3i, int] = {}
var voxel_tool: VoxelTool


func _ready() -> void:
	voxel_tool = voxel_terrain.get_voxel_tool()


func _process(delta: float) -> void:
	if blocks_queue:
		for pos in blocks_queue.keys():
			if voxel_tool.is_area_editable(AABB(pos, Vector3.ONE)):
				_set_block(blocks_queue[pos], pos)
				blocks_queue.erase(pos)


@rpc("any_peer", "call_local", "reliable")
func _set_block(id: int, pos: Vector3i) -> void:
	voxel_tool.set_voxel(pos, id)
	if multiplayer.is_server():
		changed_blocks[pos] = id


@rpc("any_peer", "call_local", "reliable")
func set_block_queue(id: int, pos: Vector3i) -> void:
	if multiplayer.is_server():
		return
	blocks_queue[pos] = id


func on_player_set_block(id: int) -> void:
	var hit_voxel: VoxelRaycastResult = _get_pointed_voxel()
	if hit_voxel:
		if id == 0:
			_set_block.rpc(id, hit_voxel.position)
		else:
			if _can_place_block(hit_voxel.previous_position):
				_set_block.rpc(id, hit_voxel.previous_position)


func _get_pointed_voxel() -> VoxelRaycastResult:
	var origin := WorldData.local_player.camera_pivot_x.get_global_transform().origin
	var forward := -WorldData.local_player.camera_pivot_x.get_global_transform().basis.z.normalized()
	var hit := voxel_tool.raycast(origin, forward, 5)
	return hit


func _can_place_block(pos: Vector3i) -> bool:
	var block_aabb = AABB(Vector3(pos), Vector3.ONE)
	
	if WorldData.local_player and \
			_get_player_aabb(WorldData.local_player.position).intersects(block_aabb):
		return false
	
	for id in WorldData.spawned_players.keys():
		var remote_player: RemotePlayer = WorldData.spawned_players[id]
		if remote_player and \
				_get_player_aabb(remote_player.position).intersects(block_aabb):
			return false
	
	return true


func _get_player_aabb(pos: Vector3) -> AABB:
	return AABB(
		pos-Vector3(0.4, 0.9, 0.4),
		Vector3(0.8, 1.8, 0.8)
	)


func get_changed_blocks() -> Dictionary[Vector3i, int]:
	return changed_blocks
