class_name Player
extends CharacterBody3D


signal set_block(id: int)

@export var mouse_sensitivity: float = 0.005

var stats: PlayerStats = preload("res://resourses/stats/player_default_stats.tres")

@onready var camera: Camera3D = %Camera3D
@onready var camera_pivot_x: Node3D = %CameraPivotX
@onready var camera_pivot_y: Node3D = %CameraPivotY
@onready var health: HealthComponent = %HealthComponent
@onready var collision: CollisionShape3D = %CollisionShape3D


func _ready() -> void:
	pass


func _process(delta: float) -> void:
	if Input.is_action_just_pressed("attack"):
		set_block.emit(0)
	if Input.is_action_just_pressed("use"):
		set_block.emit(1)


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
