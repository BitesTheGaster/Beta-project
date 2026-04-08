class_name GameWorld
extends Node3D
## Game world


const PLAYER_SPAWN_POS: Vector3 = Vector3(0, 128, 0)
const GENERATOR = preload("res://scripts/world/voxel_generator.gd")

@export var sync_rate: float = 0.05

var sync_timer: float = 0.0

@onready var player_scene = preload("res://scenes/player/player.tscn")
@onready var remote_player_scene = preload("res://scenes/player/remote_player.tscn")
@onready var voxel_terrain: VoxelTerrain = %VoxelTerrain
@onready var block_manager: BlockManager = %BlockManager


func _ready() -> void:
	if NetworkManager.is_server:
		_spawn_player(multiplayer.get_unique_id())
	
	multiplayer.peer_connected.connect(_on_peer_connected)
	multiplayer.peer_disconnected.connect(_on_peer_disconnected)


func _process(delta: float) -> void:
	if not WorldData.local_player:
		return
	
	sync_timer += delta
	if sync_timer >= sync_rate:
		sync_timer = 0.0
		_rpc_sync_position.rpc(
				WorldData.local_player.global_position,
				WorldData.local_player.rotation,
				WorldData.local_player.get_camera_rotation()
		)


func _on_peer_connected(id: int) -> void:
	if not NetworkManager.is_server:
		return
	
	for player_id in WorldData.spawned_players.keys():
		var remote_player = WorldData.spawned_players[player_id]
		_spawn_player.rpc_id(id, player_id, remote_player.position)
	_spawn_player.rpc_id(id, multiplayer.get_unique_id(), WorldData.local_player.position)
	for pos in block_manager.get_changed_blocks().keys():
		block_manager.set_block_queue.rpc_id(id, block_manager.get_changed_blocks()[pos], pos)
	
	
	_spawn_player.rpc(id)



func _on_peer_disconnected(id: int) -> void:
	if NetworkManager.is_server:
		if id in WorldData.spawned_players:
			_delete_player.rpc(id)
	# Close game if host leaves
	elif id == 1:
		get_tree().quit()
	


@rpc("authority", "call_local", "reliable")
func _spawn_player(id: int, player_position: Vector3 = PLAYER_SPAWN_POS) -> void:
	if id in WorldData.spawned_players:
		return
	
	if id == multiplayer.get_unique_id():
		var player = player_scene.instantiate()
		player.position = player_position
		player.set_multiplayer_authority(id)
		
		add_child(player)
		
		WorldData.local_player = player
		WorldData.local_player.set_block.connect(block_manager.on_player_set_block)
		print("[GameWorld] Local player spawned: " + str(id))
	else:
		var remote_player = remote_player_scene.instantiate()
		remote_player.position = player_position
		remote_player.set_multiplayer_authority(id)
		
		add_child(remote_player)
		
		WorldData.spawned_players[id] = remote_player
		print("[GameWorld] Player spawned: " + str(id))


@rpc("authority", "call_local", "reliable")
func _delete_player(id: int) -> void:
	WorldData.spawned_players[id].queue_free()
	WorldData.spawned_players.erase(id)
	print("[GameWorld] Player deleted: " + str(id))


@rpc("any_peer", "call_remote", "reliable")
func _rpc_sync_position(pos: Vector3, rot: Vector3, camera_pivot_rot: Vector3) -> void:
	var sender_id: int = multiplayer.get_remote_sender_id()
	WorldData.spawned_players[sender_id].target_positiom = pos
	WorldData.spawned_players[sender_id].rotation = rot
	WorldData.spawned_players[sender_id].camera_pivot_x.rotation.x = camera_pivot_rot.x
	WorldData.spawned_players[sender_id].camera_pivot_y.rotation.y = camera_pivot_rot.y
