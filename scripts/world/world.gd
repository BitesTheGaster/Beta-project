class_name GameWorld
extends Node3D
## Game world


var local_player: Player
var spawned_players: Dictionary[int, RemotePlayer] = {}
var changed_blocks: Dictionary[Vector3i, int] = {}
var blocks_queue: Dictionary[Vector3i, int] = {}

@onready var voxel_terrain: VoxelTerrain = %VoxelTerrain
@onready var block_manager: BlockManager = %BlockManager
@onready var network_synchronizer: NetworkSynchronizer = %NetworkSynchronizer
@onready var action_queue: ActionQueue = %ActionQueue
@onready var server_action_handler: ServerActionHandler = %ServerActionHandler


func _physics_process(delta: float) -> void:
	for player in spawned_players.values():
		local_player.interact_with_mob(player)
