extends Node3D


@onready var world: GameWorld = get_parent()


func _process(delta: float) -> void:
	if not world.local_player:
		return


func on_player_death():
	world.local_player.health.respawn()
	world.local_player.reset_physics()
	world.local_player.position = world.network_synchronizer.PLAYER_SPAWN_POS
