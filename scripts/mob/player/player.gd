class_name Player
extends Mob


signal set_block(id: int)

@onready var camera_pivot_x: Node3D = %CameraPivotX
@onready var camera_pivot_y: Node3D = %CameraPivotY
@onready var health: HealthComponent = %HealthComponent
@onready var collision: CollisionShape3D = %CollisionShape
@onready var raycast: RayCast3D = %Raycast
@onready var camera_spring_arm: SpringArm3D = %CameraSpringArm
@onready var body: MeshInstance3D = %Body

# TEMP
var current_block: int = 1

func _ready() -> void:
	#stats.max_health = health.max_health
	health.health_changed.emit(health.current_health, health.max_health)


func _process(delta: float) -> void:
	if Input.is_action_just_pressed("attack"):
		raycast.force_raycast_update()
		var target = raycast.get_collider()
		if target is RemotePlayer:
			health.take_damage.rpc_id(target.get_multiplayer_authority(), 1)
		else:
			set_block.emit(0)
	if Input.is_action_just_pressed("use"):
		set_block.emit(current_block)
	if Input.is_action_just_pressed("slot1"):
		current_block = 1
	if Input.is_action_just_pressed("slot2"):
		current_block = 2
	if Input.is_action_just_pressed("slot3"):
		current_block = 3


func get_camera_rotation() -> Vector3:
	return Vector3(
		camera_pivot_x.rotation.x,
		camera_pivot_y.rotation.y,
		0
	)
