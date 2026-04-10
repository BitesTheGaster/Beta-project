class_name State
extends Node
## Template for states


@export var state_machine: StateMachine


func update(delta: float) -> void:
	pass


func physics_update(delta: float) -> void:
	pass


func update_input(event: InputEvent) -> void:
	pass


func update_key_input(event: InputEvent) -> void:
	pass


func enter() -> void:
	pass


func exit() -> void:
	pass
