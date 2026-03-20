@abstract
class_name State
extends Node
## Template for states

var state_machine: StateMachine = get_parent()


func update(delta: float) -> void:
	pass


func physics_update(delta: float) -> void:
	pass


func update_input(event: InputEvent) -> void:
	pass


func enter() -> void:
	pass


func exit() -> void:
	pass
