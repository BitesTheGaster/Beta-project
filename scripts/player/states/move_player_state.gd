extends PlayerState
## Move player state


func _ready() -> void:
	name = "move"


func update(delta: float) -> void:
	pass


func physics_update(delta: float) -> void:
	# Gravity
	player.apply_gravity(delta)
	
	# Input
	var input_dir = get_input_dir()
	var direction = (player.camera_pivot_y.transform.basis
			* Vector3(input_dir.x, 0, input_dir.y)).normalized()
	
	# Movement
	player.velocity.x = direction.x * player.stats.speed
	player.velocity.z = direction.z * player.stats.speed
	
	# Jump
	if Input.is_action_pressed("jump") and player.is_on_floor():
		player.velocity.y = player.stats.jump_velocity
	
	# State transitions
	if not player.is_on_floor():
		state_machine.change_state("airborne")
	elif not input_dir:
		state_machine.change_state("idle")
	
	player.move_and_slide()


func update_input(event: InputEvent) -> void:
	pass


func enter() -> void:
	pass


func exit() -> void:
	pass
