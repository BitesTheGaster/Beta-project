class_name RemotePlayer
extends Mob
##


var peer_id: int
var target_position := Vector3.ZERO
var predicted_velocity := Vector3.ZERO
var interpolation_speed: float = 20.0


@onready var camera_pivot_x: Node3D = %CameraPivotX
@onready var camera_pivot_y: Node3D = %CameraPivotY


func _physics_process(delta):
	global_position = global_position.lerp(target_position, interpolation_speed * delta)
	velocity = predicted_velocity
