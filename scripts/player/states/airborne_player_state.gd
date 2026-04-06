extends PlayerState
## Airborne player state


func _ready() -> void:
	name = "airborne"


func update(delta: float) -> void:
	pass


func physics_update(delta: float) -> void:
	# Gravity
	player.apply_gravity(delta)
	
	var input_dir = get_input_dir()
	var direction = (player.camera_pivot_y.transform.basis
			* Vector3(input_dir.x, 0, input_dir.y)).normalized()
	
	# Less control in air
	player.velocity.x = lerp(player.velocity.x, direction.x * player.stats.speed, 0.1)
	player.velocity.z = lerp(player.velocity.z, direction.z * player.stats.speed, 0.1)
	
	# State transitions
	if player.is_on_floor():
		if is_moving():
			state_machine.change_state("move")
		else:
			state_machine.change_state("idle")
	
	player.move_and_slide()


func update_input(event: InputEvent) -> void:
	pass


func enter() -> void:
	pass


func exit() -> void:
	pass
