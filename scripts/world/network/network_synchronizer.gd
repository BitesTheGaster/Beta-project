class_name NetworkSynchronizer
extends Node
##


signal local_player_spawned(local_player: Player)

const PLAYER_SPAWN_POS: Vector3 = Vector3(0, 128, 0)

@export var sync_rate: float = 0.03

var sync_timer: float = 0.0

@onready var player_scene = preload("res://scenes/player/player.tscn")
@onready var remote_player_scene = preload("res://scenes/player/remote_player.tscn")
@onready var world: GameWorld = get_parent()
@onready var players_container: Node3D = %PlayersContainer


func _ready() -> void:
	if multiplayer.is_server():
		await get_tree().process_frame
		_spawn_player(multiplayer.get_unique_id())
	
	multiplayer.peer_connected.connect(_on_peer_connected)
	multiplayer.peer_disconnected.connect(_on_peer_disconnected)


func _process(delta: float) -> void:
	if not world.local_player:
		return
	
	sync_timer += delta
	if sync_timer >= sync_rate:
		sync_timer = 0.0
		_rpc_sync_position.rpc(
				world.local_player.global_position,
				world.local_player.rotation,
				world.local_player.get_camera_rotation(),
				world.local_player.velocity,
		)


func _on_peer_connected(id: int) -> void:
	if not multiplayer.is_server():
		return
	
	for player_id in world.spawned_players.keys():
		var remote_player = world.spawned_players[player_id]
		_spawn_player.rpc_id(id, player_id, remote_player.position)
	_spawn_player.rpc_id(id, multiplayer.get_unique_id(), world.local_player.position)
	for pos in world.changed_blocks.keys():
		world.block_manager.set_block_queue.rpc_id(id, world.changed_blocks[pos], pos)
	
	
	_spawn_player.rpc(id)


func _on_peer_disconnected(id: int) -> void:
	if multiplayer.is_server():
		if id in world.spawned_players:
			_delete_player.rpc(id)
	# Close game if host leaves
	elif id == 1:
		get_tree().quit()


@rpc("authority", "call_local", "reliable")
func _spawn_player(id: int, player_position: Vector3 = PLAYER_SPAWN_POS) -> void:
	if id in world.spawned_players:
		return
	
	if id == multiplayer.get_unique_id():
		var player: Player = player_scene.instantiate()
		player.position = player_position
		player.set_multiplayer_authority(id)
		
		players_container.add_child(player)
		
		world.local_player = player
		world.local_player.voxel_terrain = world.voxel_terrain
		world.local_player.set_block.connect(world.block_manager.on_player_set_block)
		world.local_player.health.died.connect(players_container.on_player_death)
		local_player_spawned.emit(world.local_player)
		print("[GameWorld] Local player spawned: " + str(id))
	else:
		var remote_player: RemotePlayer = remote_player_scene.instantiate()
		remote_player.position = player_position
		remote_player.set_multiplayer_authority(id)
		
		players_container.add_child(remote_player)
		
		world.spawned_players[id] = remote_player
		print("[GameWorld] Player spawned: " + str(id))


@rpc("authority", "call_local", "reliable")
func _delete_player(id: int) -> void:
	world.spawned_players[id].queue_free()
	world.spawned_players.erase(id)
	print("[GameWorld] Player deleted: " + str(id))


@rpc("any_peer", "call_remote", "unreliable")
func _rpc_sync_position(pos: Vector3, rot: Vector3, camera_pivot_rot: Vector3, velocity: Vector3) -> void:
	var sender_id: int = multiplayer.get_remote_sender_id()
	world.spawned_players[sender_id].target_position = pos
	world.spawned_players[sender_id].rotation = rot
	world.spawned_players[sender_id].camera_pivot_x.rotation.x = camera_pivot_rot.x
	world.spawned_players[sender_id].camera_pivot_y.rotation.y = camera_pivot_rot.y
	world.spawned_players[sender_id].predicted_velocity = velocity
