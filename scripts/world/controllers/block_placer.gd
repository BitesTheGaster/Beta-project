extends Node
## Controls block placing


@export var voxel_terrain: VoxelTerrain

var voxel_tool: VoxelTool


func _ready() -> void:
	voxel_tool = voxel_terrain.get_voxel_tool()
