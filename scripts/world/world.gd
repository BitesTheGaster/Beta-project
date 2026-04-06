class_name GameWorld
extends Node3D
## Game world


const PLAYER_SPAWN_POS: Vector3 = Vector3(0, 128, 0)
const GENERATOR = preload("res://scripts/world/voxel_generator.gd")

@export var sync_rate: float = 0.05

var sync_timer: float = 0.0
var local_player: Player
var spawned_players: Dictionary[int, RemotePlayer] = {}
var changed_blocks: Dictionary[Vector3i, int] = {}
var blocks_queue: Dictionary[Vector3i, int] = {}
var voxel_tool: VoxelTool

@onready var player_scene = preload("res://scenes/player/player.tscn")
@onready var remote_player_scene = preload("res://scenes/player/remote_player.tscn")
@onready var voxel_terrain: VoxelTerrain = %VoxelTerrain


func _ready() -> void:
	if NetworkManager.is_server:
		_spawn_player(multiplayer.get_unique_id())
	
	multiplayer.peer_connected.connect(_on_peer_connected)
	multiplayer.peer_disconnected.connect(_on_peer_disconnected)
	
	voxel_tool = voxel_terrain.get_voxel_tool()


func _process(delta: float) -> void:
	if not local_player:
		return
	
	if blocks_queue:
		for pos in blocks_queue.keys():
			if voxel_tool.is_area_editable(AABB(pos, Vector3.ONE)):
				_set_block(blocks_queue[pos], pos)
				blocks_queue.erase(pos)
	
	sync_timer += delta
	if sync_timer >= sync_rate:
		sync_timer = 0.0
		_rpc_sync_position.rpc(
				local_player.global_position,
				local_player.rotation,
				local_player.get_camera_rotation()
		)


func _on_peer_connected(id: int) -> void:
	if not NetworkManager.is_server:
		return
	
	for player_id in spawned_players.keys():
		var remote_player = spawned_players[player_id]
		_spawn_player.rpc_id(id, player_id, remote_player.position)
	_spawn_player.rpc_id(id, multiplayer.get_unique_id(), local_player.position)
	for pos in changed_blocks.keys():
		_set_block_queue.rpc_id(id, changed_blocks[pos], pos)
	
	
	_spawn_player.rpc(id)



func _on_peer_disconnected(id: int) -> void:
	if NetworkManager.is_server:
		if id in spawned_players:
			_delete_player.rpc(id)
	# Close game if host leaves
	elif id == 1:
		get_tree().quit()
	


@rpc("authority", "call_local", "reliable")
func _spawn_player(id: int, player_position: Vector3 = PLAYER_SPAWN_POS) -> void:
	if id in spawned_players:
		return
	
	if id == multiplayer.get_unique_id():
		var player = player_scene.instantiate()
		player.position = player_position
		player.set_multiplayer_authority(id)
		
		add_child(player)
		
		local_player = player
		local_player.set_block.connect(_on_player_set_block)
		print("[GameWorld] Local player spawned: " + str(id))
	else:
		var remote_player = remote_player_scene.instantiate()
		remote_player.position = player_position
		remote_player.set_multiplayer_authority(id)
		
		add_child(remote_player)
		
		spawned_players[id] = remote_player
		print("[GameWorld] Player spawned: " + str(id))


@rpc("authority", "call_local", "reliable")
func _delete_player(id: int) -> void:
	spawned_players[id].queue_free()
	spawned_players.erase(id)
	print("[GameWorld] Player deleted: " + str(id))


@rpc("any_peer", "call_remote", "reliable")
func _rpc_sync_position(pos: Vector3, rot: Vector3, camera_pivot_rot: Vector3) -> void:
	var sender_id: int = multiplayer.get_remote_sender_id()
	spawned_players[sender_id].target_positiom = pos
	spawned_players[sender_id].rotation = rot
	spawned_players[sender_id].camera_pivot_x.rotation.x = camera_pivot_rot.x
	spawned_players[sender_id].camera_pivot_y.rotation.y = camera_pivot_rot.y


@rpc("any_peer", "call_local", "reliable")
func _set_block(id: int, pos: Vector3i) -> void:
	voxel_tool.set_voxel(pos, id)
	if multiplayer.is_server():
		changed_blocks[pos] = id


@rpc("any_peer", "call_local", "reliable")
func _set_block_queue(id: int, pos: Vector3i) -> void:
	if multiplayer.is_server():
		return
	blocks_queue[pos] = id


func _on_player_set_block(id: int) -> void:
	var hit_voxel: VoxelRaycastResult = _get_pointed_voxel()
	if hit_voxel:
		if id == 0:
			_set_block.rpc(id, hit_voxel.position)
		else:
			if _can_place_block(hit_voxel.previous_position):
				_set_block.rpc(id, hit_voxel.previous_position)


func _get_pointed_voxel() -> VoxelRaycastResult:
	var origin := local_player.camera_pivot_x.get_global_transform().origin
	var forward := -local_player.camera_pivot_x.get_global_transform().basis.z.normalized()
	var hit := voxel_tool.raycast(origin, forward, 5)
	return hit


func _can_place_block(pos: Vector3i) -> bool:
	var block_aabb = AABB(Vector3(pos), Vector3.ONE)
	
	if local_player and \
			_get_player_aabb(local_player.position).intersects(block_aabb):
		return false
	
	for id in spawned_players.keys():
		var remote_player: RemotePlayer = spawned_players[id]
		if remote_player and \
				_get_player_aabb(remote_player.position).intersects(block_aabb):
			return false
	
	return true


func _get_player_aabb(pos: Vector3) -> AABB:
	return AABB(
		pos-Vector3(0.4, 0.9, 0.4),
		Vector3(0.8, 1.8, 0.8)
	)
