class_name Player
extends CharacterBody3D


signal player_died()

@export var mouse_sensitivity: float = 0.005

var stats: PlayerStats = preload("res://resourses/stats/player_default_stats.tres")
var is_local: bool = true

@onready var camera: Camera3D = %Camera3D
@onready var camera_pivot: Node3D = %CameraPivot
@onready var health: HealthComponent = %HealthComponent
@onready var meshes: Array[MeshInstance3D] = [
	%BodyMesh,
	%FaceMesh,
]


func _ready() -> void:
	if is_local:
		camera.current = true
		for mesh in meshes:
			mesh.set_layer_mask_value(1, false)


func _unhandled_input(event: InputEvent) -> void:
	if not is_local:
		return
	
	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		camera_pivot.rotation.x -= event.relative.y * mouse_sensitivity
		camera_pivot.rotation.x = clamp(camera_pivot.rotation.x, -PI/2, PI/2)
		self.rotation.y -= event.relative.x * mouse_sensitivity


func apply_gravity(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta
