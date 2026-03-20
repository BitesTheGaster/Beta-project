class_name PlayerStateMachine
extends StateMachine
## State machine for player


@export var player: Player


func _process(delta: float) -> void:
	if not player.is_local:
		return
	
	current_state.update(delta)


func _physics_process(delta: float) -> void:
	if not player.is_local:
		return
	
	current_state.physics_update(delta)


func _unhandled_input(event: InputEvent) -> void:
	if not player.is_local:
		return
	
	current_state.update_input(event)
