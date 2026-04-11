extends PlayerState
## Move player state


func _ready() -> void:
	name = "move"


func update(delta: float) -> void:
	# State transitions
	if not player.is_on_floor:
		state_machine.change_state("airborne")
	elif not is_moving():
		state_machine.change_state("idle")


func physics_update(delta: float) -> void:
	# Jump
	if Input.is_action_pressed("jump"):
		player.jump()
	
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
