class_name RemotePlayer
extends StaticBody3D
##


var target_positiom := Vector3.ZERO

@onready var camera_pivot_x: Node3D = %CameraPivotX
@onready var camera_pivot_y: Node3D = %CameraPivotY

func _physics_process(delta: float) -> void:
	global_position = global_position.lerp(target_positiom, 0.33)
