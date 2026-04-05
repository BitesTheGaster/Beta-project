class_name Player
extends CharacterBody3D


signal set_block(id: int)

enum CameraMode {FIRST, THIRD, THIRD_ALT}

@export var mouse_sensitivity: float = 0.005

var stats: PlayerStats = preload("res://resourses/stats/player_default_stats.tres")
var camera_mode: CameraMode = 0

@onready var camera: Camera3D = %Camera
@onready var camera_pivot_x: Node3D = %CameraPivotX
@onready var camera_pivot_y: Node3D = %CameraPivotY
@onready var health: HealthComponent = %HealthComponent
@onready var collision: CollisionShape3D = %CollisionShape
@onready var interaction_ray: RayCast3D = %InteractionRay
@onready var camera_spring_arm: SpringArm3D = %CameraSpringArm
@onready var body: MeshInstance3D = %Body


func _ready() -> void:
	_update_camera_mode()


func _process(delta: float) -> void:
	if Input.is_action_just_pressed("attack"):
		set_block.emit(0)
	if Input.is_action_just_pressed("use"):
		set_block.emit(1)
	if Input.is_action_just_pressed("change_camera_mode"):
		camera_mode = (int(camera_mode) + 1)%3
		_update_camera_mode()


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		camera_pivot_x.rotation.x -= event.relative.y * mouse_sensitivity
		camera_pivot_x.rotation.x = clamp(camera_pivot_x.rotation.x, -PI/2, PI/2)
		camera_pivot_y.rotation.y -= event.relative.x * mouse_sensitivity


func apply_gravity(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta


func get_camera_rotation() -> Vector3:
	return Vector3(
		camera_pivot_x.rotation.x,
		camera_pivot_y.rotation.y,
		0
	)


func _update_camera_mode() -> void:
	if camera_mode == CameraMode.FIRST:
		camera_spring_arm.spring_length = 0.0
		camera.rotation.y = 0
		body.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_SHADOWS_ONLY
	elif camera_mode == CameraMode.THIRD:
		camera_spring_arm.spring_length = 3.0
		camera.rotation.y = 0
		body.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_ON
	elif camera_mode == CameraMode.THIRD_ALT:
		camera_spring_arm.spring_length = -3.0
		camera.rotation.y = PI
		body.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_ON
