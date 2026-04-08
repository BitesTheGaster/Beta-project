class_name Player
extends CharacterBody3D


signal set_block(id: int)

var stats: PlayerStats = preload("res://resourses/player/player_default_stats.tres")

@onready var camera_pivot_x: Node3D = %CameraPivotX
@onready var camera_pivot_y: Node3D = %CameraPivotY
@onready var health: HealthComponent = %HealthComponent
@onready var collision: CollisionShape3D = %CollisionShape
@onready var interaction_ray: RayCast3D = %InteractionRay
@onready var camera_spring_arm: SpringArm3D = %CameraSpringArm
@onready var body: MeshInstance3D = %Body


func _ready() -> void:
	pass


func _process(delta: float) -> void:
	if Input.is_action_just_pressed("attack"):
		set_block.emit(0)
	if Input.is_action_just_pressed("use"):
		set_block.emit(1)


func apply_gravity(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta


func get_camera_rotation() -> Vector3:
	return Vector3(
		camera_pivot_x.rotation.x,
		camera_pivot_y.rotation.y,
		0
	)
