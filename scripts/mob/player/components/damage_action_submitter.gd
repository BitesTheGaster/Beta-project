class_name DamageActionSubmitter
extends Node


@export var player: Player


func submit(target: RemotePlayer) -> void:
	if not player.queue: return
	
	var action = DamageAction.new()
	action.target_id = target.player_id
	action.damage = 10.0
	action.source_position = player.camera_pivot_x.global_position
	action.sender_id = multiplayer.get_unique_id()
	
	player.queue.submit(
		action,
		Callable(self, "_on_damage_success"),
		Callable(self, "_on_damage_failure")
	)


func _on_damage_success(a: DamageAction):
	pass


func _on_damage_failure(reason: String, a: DamageAction):
	print("Player ", a.target_id, " not damaged: ", reason)
