extends PlayerState
## Airborne player state


func _ready() -> void:
	name = "airborne"


func update(delta: float) -> void:
	# State transitions
	if player.is_on_floor:
		if is_moving():
			state_machine.change_state("move")
		else:
			state_machine.change_state("idle")


func physics_update(delta: float) -> void:
	# Get input and move
	var input_dir = get_input_dir()
	var direction = (player.camera_pivot_y.transform.basis
			* Vector3(input_dir.x, 0, input_dir.y)).normalized()
	player.move_dir = direction


func update_input(event: InputEvent) -> void:
	pass


func update_key_input(event: InputEvent) -> void:
	pass


func enter() -> void:
	pass


func exit() -> void:
	pass
