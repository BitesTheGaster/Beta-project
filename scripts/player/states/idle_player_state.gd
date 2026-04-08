extends PlayerState
## Idle player state


func _ready() -> void:
	name = "idle"


func update(delta: float) -> void:
	pass


func physics_update(delta: float) -> void:
	# Gravity
	player.apply_gravity(delta)
	
	# Jump
	if Input.is_action_pressed("jump") and player.is_on_floor():
		player.velocity.y += player.stats.jump_velocity
	
	# State transitions
	if not player.is_on_floor():
		state_machine.change_state("airborne")
	elif is_moving():
		state_machine.change_state("move")
	
	player.move_and_slide()


func update_input(event: InputEvent) -> void:
	pass


func enter() -> void:
	player.velocity.x = 0
	player.velocity.z = 0


func exit() -> void:
	pass
