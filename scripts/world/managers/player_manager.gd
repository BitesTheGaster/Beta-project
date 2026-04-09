class_name PlayerManager
extends Node


var local_player: Player

@onready var world: GameWorld = get_parent()


func _on_local_player_spawned(local_player: Player):
	pass


@rpc("any_peer", "call_remote", "reliable")
func rpc_take_damage(damage: int):
	pass
