class_name PlayersContainer
extends Node3D
## Player container

@onready var world: GameWorld = get_parent()


func _process(delta: float) -> void:
	if not world.local_player:
		return


# TODO add spawn protection
# TODO add normal spawn position
# TODO i have to delete player and spawn new after death(maybe)
func on_player_death(player_id: int) -> void:
	if player_id == multiplayer.get_unique_id():
		world.local_player.health.respawn()
		world.local_player.reset_physics()
		world.local_player.position = world.network_synchronizer.PLAYER_SPAWN_POS
	else:
		world.spawned_players[player_id].health.respawn()
		world.spawned_players[player_id].reset_physics()
		world.spawned_players[player_id].position = world.network_synchronizer.PLAYER_SPAWN_POS


@rpc("authority", "call_local", "reliable")
func request_damage(target_id: int, amount: float, source: Vector3) -> void:
	if target_id == multiplayer.get_unique_id():
		world.local_player.health.take_damage(amount, source)
	else:
		world.spawned_players[target_id].health.take_damage(amount, source)
