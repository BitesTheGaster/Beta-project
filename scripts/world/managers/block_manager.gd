class_name BlockManager
extends Node
## Controls block placing


@export var voxel_terrain: VoxelTerrain

var voxel_tool: VoxelTool

@onready var world: GameWorld = get_parent()

func _ready() -> void:
	voxel_tool = voxel_terrain.get_voxel_tool()


func _process(delta: float) -> void:
	if world.blocks_queue:
		for pos in world.blocks_queue.keys():
			if voxel_tool.is_area_editable(AABB(pos, Vector3.ONE)):
				set_block(world.blocks_queue[pos], pos)
				world.blocks_queue.erase(pos)


@rpc("authority", "call_local", "reliable")
func set_block(id: int, pos: Vector3i) -> void:
	if voxel_tool and voxel_tool.is_area_editable(AABB(pos, Vector3.ONE)):
		voxel_tool.set_voxel(pos, id)
		if multiplayer.is_server():
			world.changed_blocks[pos] = id


@rpc("authority", "call_local", "reliable")
func set_block_queue(id: int, pos: Vector3i) -> void:
	if multiplayer.is_server():
		return
	world.blocks_queue[pos] = id


#func _can_place_block(pos: Vector3i) -> bool:
	#var block_aabb = AABB(Vector3(pos), Vector3.ONE)
	#
	#if world.local_player and \
			#_get_player_aabb(world.local_player.position).intersects(block_aabb):
		#return false
	#
	#for id in world.spawned_players.keys():
		#var remote_player: RemotePlayer = world.spawned_players[id]
		#if remote_player and \
				#_get_player_aabb(remote_player.position).intersects(block_aabb):
			#return false
	#
	#return true
#
#
#func _get_player_aabb(pos: Vector3) -> AABB:
	#return AABB(
		#pos-Vector3(0.4, 0.9, 0.4),
		#Vector3(0.8, 1.8, 0.8)
	#)


func execute_block_action(action: PlaceBlockAction) -> bool:
	if not voxel_tool.is_area_editable(AABB(action.position, Vector3.ONE)):
		return false
	
	voxel_tool.set_voxel(action.position, action.block_id)
	
	if multiplayer.is_server():
		world.changed_blocks[action.position] = action.block_id
	
	return true
