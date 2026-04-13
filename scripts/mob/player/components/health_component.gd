@icon("res://assets/icons/health_component.png")
class_name HealthComponent
extends Node
## Health component


signal health_changed(new_hp: float, max_hp: float)
signal died()
signal respawned()
signal damaged(source: Vector3)

@export var max_health: float = 100.0

var current_health: float = 100.0


@rpc("any_peer", "call_remote", "reliable")
func take_damage(amount: float, source: Vector3) -> void:
	current_health -= amount
	health_changed.emit(current_health, max_health)
	if current_health <= 0:
		died.emit()
	else:
		damaged.emit(source)


func respawn() -> void:
	current_health = max_health
	health_changed.emit(current_health, max_health)
	respawned.emit()
