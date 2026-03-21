class_name GameWorld
extends Node3D
## Game world


var local_player: Player
var spawned_players: Dictionary[int, Player] = {}

@onready var player_scene = preload("res://scenes/player/player.tscn")


func _ready() -> void:
	if NetworkManager.is_server:
		_spawn_player.rpc(multiplayer.get_unique_id())
	
	multiplayer.peer_connected.connect(_on_peer_connected)
	multiplayer.peer_disconnected.connect(_on_peer_disconnected)


func _on_peer_connected(id: int) -> void:
	if not NetworkManager.is_server:
		return
	
	for player_id in spawned_players.keys():
		var player = spawned_players[player_id]
		_spawn_player.rpc_id(id, player_id, player.position)
	
	_spawn_player.rpc(id)



func _on_peer_disconnected(id: int):
	if NetworkManager.is_server:
		if id in spawned_players:
			_delete_player.rpc(id)
	# Close game if host leaves
	elif id == 1:
		get_tree().quit()
	


@rpc("authority", "call_local", "reliable")
func _spawn_player(id: int, player_position: Vector3 = Vector3.ZERO) -> void:
	if id in spawned_players:
		return
	
	var player = player_scene.instantiate()
	player.position = Vector3.ZERO
	
	player.set_multiplayer_authority(id)
	
	add_child(player)
	
	if NetworkManager.is_server:
		spawned_players[id] = player
	
	if id == multiplayer.get_unique_id():
		local_player = player
		player.camera.current = true
		for mesh in player.meshes:
			mesh.set_layer_mask_value(1, false)
		print("[GameWorld] Local player spawned: " + str(id))
	else:
		print("[GameWorld] Player spawned: " + str(id))


@rpc("authority", "call_local", "reliable")
func _delete_player(id: int):
	spawned_players[id].queue_free()
	spawned_players.erase(id)
	print("[GameWorld] Player deleted: " + str(id))
