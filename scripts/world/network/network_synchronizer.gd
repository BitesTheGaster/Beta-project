class_name PlayerSpawner
extends Node
##


signal local_player_spawned(local_player: Player)

const PLAYER_SPAWN_POS: Vector3 = Vector3(0, 128, 0)

@export var world: GameWorld

@onready var player_scene = preload("res://scenes/player/player.tscn")
@onready var remote_player_scene = preload("res://scenes/player/remote_player.tscn")


func _ready() -> void:
	if multiplayer.is_server():
		await get_tree().process_frame
		_spawn_player(multiplayer.get_unique_id())
	
	multiplayer.peer_connected.connect(_on_peer_connected)
	multiplayer.peer_disconnected.connect(_on_peer_disconnected)


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
		
		world.players_container.add_child(player)
		
		player.health.player_id = id
		player.voxel_terrain = world.voxel_terrain
		player.health.died.connect(world.players_container.on_player_death)
		player.queue = world.action_queue
		player.voxel_tool = world.voxel_terrain.get_voxel_tool()
		local_player_spawned.emit(player)
		
		world.local_player = player
		print("[GameWorld] Local player spawned: " + str(id))
	else:
		var remote_player: RemotePlayer = remote_player_scene.instantiate()
		remote_player.position = player_position
		remote_player.player_id = id
		
		world.players_container.add_child(remote_player)
		
		remote_player.health.player_id = id
		remote_player.health.died.connect(world.players_container.on_player_death)
		remote_player.voxel_terrain = world.voxel_terrain
		
		world.spawned_players[id] = remote_player
		print("[GameWorld] Player spawned: " + str(id))


@rpc("authority", "call_local", "reliable")
func _delete_player(id: int) -> void:
	world.spawned_players[id].queue_free()
	world.spawned_players.erase(id)
	print("[GameWorld] Player deleted: " + str(id))
