class_name PlayerState
extends State
## State for player


var player: Player:
	get:
		if state_machine and state_machine is PlayerStateMachine:
			return state_machine.player
		return null


func get_input_dir() -> Vector2:
	return Input.get_vector("left", "right", "forward", "back")


func is_moving() -> bool:
	return get_input_dir().length() > 0.1
