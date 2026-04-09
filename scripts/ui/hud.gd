class_name Hud
extends CanvasLayer
##


func set_health_bar_value(new_health: int, max_health: int):
	%HealthBar.value = new_health
	%HealthBar.max_value = max_health
