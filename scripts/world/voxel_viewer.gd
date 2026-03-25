extends VoxelViewer
##


@export var update_interval: float = 0.2

var target: Player
var update_timer: float = 0.0

func _process(delta: float) -> void:
	update_timer += delta
	if update_timer >= update_interval:
		update_timer = 0
		if target:
			position = target.position
