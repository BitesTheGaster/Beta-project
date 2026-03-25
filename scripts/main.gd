extends Node3D
## Main


@onready var world_scene = preload("res://scenes/world/world.tscn")
@onready var main_menu: MainMenu = %MainMenu


func _ready() -> void:
	main_menu.world_entered.connect(_on_world_entered)


func _on_world_entered():
	main_menu.hide()
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	var world: GameWorld = world_scene.instantiate()
	add_child(world)
