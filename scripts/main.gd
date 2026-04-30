extends Node3D
## Main


var world: GameWorld

@onready var world_scene = preload("res://scenes/world/world.tscn")
@onready var main_menu: MainMenu = %MainMenu
@onready var hud: Hud = %Hud


func _ready() -> void:
	main_menu.world_entered.connect(_on_world_entered)


func _on_world_entered() -> void:
	main_menu.hide()
	hud.show()
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	world = world_scene.instantiate()
	add_child(world)
	world.player_spawner.local_player_spawned.connect(_on_local_player_spawned)


func _on_world_exited() -> void:
	pass # TODO Save system


func _on_local_player_spawned(local_player: Player) -> void:
	local_player.health.health_changed.connect(hud.set_health_bar_value)
