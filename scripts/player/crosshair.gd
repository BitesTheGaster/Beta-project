extends Sprite2D
##


func _process(delta: float) -> void:
	scale.x = get_viewport().get_visible_rect().size.x / 1000.0
	scale.y = get_viewport().get_visible_rect().size.x / 1000.0
	position.x = get_viewport().get_visible_rect().size.x / 2.0
	position.y = get_viewport().get_visible_rect().size.y / 2.0
	
