extends Node3D


@onready var world: GameWorld = get_parent()


func _process(delta: float) -> void:
	if not world.local_player:
		return

# How i can fix that player can take damage after death: add spawn protection
# TODO add spawn protection
# TODO add normal spawn position
# TODO i have to delete player and spawn new after death
func on_player_death():
	world.local_player.health.respawn()
	world.local_player.reset_physics()
	world.local_player.position = world.network_synchronizer.PLAYER_SPAWN_POS
