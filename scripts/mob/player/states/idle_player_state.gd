extends PlayerState
## Idle player state


func _ready() -> void:
	name = "idle"


func update(delta: float) -> void:
	# State transitions
	if not player.is_on_floor:
		state_machine.change_state("airborne")
	elif is_moving():
		state_machine.change_state("move")


func physics_update(delta: float) -> void:
	# Jump
	if Input.is_action_pressed("jump"):
		player.jump()


func update_input(event: InputEvent) -> void:
	pass


func update_key_input(event: InputEvent) -> void:
	pass


func enter() -> void:
	pass


func exit() -> void:
	pass
