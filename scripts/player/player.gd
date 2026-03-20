class_name Player
extends CharacterBody3D


signal player_died()

@export var mouse_sensitivity: float = 0.005

var stats: PlayerStats = preload("res://resourses/stats/player_default_stats.tres")

@onready var camera_pivot: Node3D = %CameraPivot
@onready var health: HealthComponent = %HealthComponent

func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		camera_pivot.rotation.x -= event.relative.y * mouse_sensitivity
		camera_pivot.rotation.x = clamp(camera_pivot.rotation.x, -PI/2, PI/2)
		self.rotation.y -= event.relative.x * mouse_sensitivity


func apply_gravity(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta
