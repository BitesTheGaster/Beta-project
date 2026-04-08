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
