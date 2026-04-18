class_name SyncComponent
extends Node


@export var player: Player

const POSITION_SYNC_DELAY: float = 0.025

var position_sync_timer := Timer.new()


func _ready() -> void:
	position_sync_timer.wait_time = POSITION_SYNC_DELAY
	position_sync_timer.timeout.connect(_send_position_update)
	position_sync_timer.name = "PositionSyncTimer"
	add_child(position_sync_timer)
	position_sync_timer.start()


func _send_position_update() -> void:
	var action = SyncPositionAction.new()
	action.position = player.position
	action.rotation = Vector3(
		player.camera_pivot_x.rotation.x,
		player.camera_pivot_y.rotation.y,
		0
	)
	action.velocity = player.velocity
	action.sender_id = multiplayer.get_unique_id()
	
	player.queue.submit(
			action,
			Callable(self, "_on_sync_position_success"),
			Callable(self, "_on_sync_position_failure")
			) 


func _on_sync_position_success(a: SyncPositionAction) -> void:
	pass


func _on_sync_position_failure(reason: String, a: SyncPositionAction) -> void:
	print("Position ", a.position," not sync: ", reason)
