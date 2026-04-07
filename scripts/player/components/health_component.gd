@icon("res://assets/icons/health_component.png")
class_name HealthComponent
extends Node
## Health component


signal health_changed(new_hp: float, max_hp: float)
signal died()

@export var max_health: float = 100.0
var current_health: float = 100.0


func take_damage(amount: float) -> void:
	current_health -= amount
	health_changed.emit(current_health, max_health)
	if current_health <= 0:
		died.emit()


@rpc("authority", "call_remote", "reliable")
func request_damage(amount: float) -> void:
	take_damage(amount)
