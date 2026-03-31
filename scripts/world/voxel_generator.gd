extends VoxelGeneratorScript

const channel: int = VoxelBuffer.CHANNEL_TYPE

const AIR: int = 0
const SAND: int = 1
const GRASS: int = 2
const DIRT: int = 3

@export var world_seed: int = 57
@export var base_height: int = -8
@export var height_scale: float = 100.0
@export var desert_threshold: float = 0.0

var noise_height: FastNoiseLite
var noise_biome: FastNoiseLite


func _init():
	_setup_noise()


func _setup_noise():
	noise_height = FastNoiseLite.new()
	noise_height.seed = world_seed
	noise_height.frequency = 0.01
	noise_height.fractal_type = FastNoiseLite.FRACTAL_FBM
	noise_height.fractal_octaves = 4
	
	noise_biome = FastNoiseLite.new()
	noise_biome.seed = world_seed + 1000
	noise_biome.frequency = 0.005
	noise_biome.fractal_type = FastNoiseLite.FRACTAL_FBM
	noise_biome.fractal_octaves = 2


func _get_used_channels_mask() -> int:
	return 1 << channel


func _generate_block(buffer: VoxelBuffer, origin: Vector3i, lod: int) -> void:
	if lod != 0:
		return
	
	var block_size = buffer.get_size()
	
	for z in range(block_size.z):
		for x in range(block_size.x):
			var world_x = origin.x + x
			var world_z = origin.z + z
			
			var biome_value = noise_biome.get_noise_2d(world_x, world_z)
			var is_desert = biome_value < desert_threshold
			
			var height_value = noise_height.get_noise_2d(world_x, world_z)
			var normalized_height = (height_value + 1.0) / 2.0
			var surface_height = base_height + int(normalized_height * height_scale)
			
			for y in range(block_size.y):
				var world_y = origin.y + y
				
				if world_y > surface_height:
					buffer.set_voxel(AIR, x, y, z, channel)
				elif is_desert:
					buffer.set_voxel(SAND, x, y, z, channel)
				else:
					if world_y == surface_height:
						buffer.set_voxel(GRASS, x, y, z, channel)
					else:
						buffer.set_voxel(DIRT, x, y, z, channel)
