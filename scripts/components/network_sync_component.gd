@icon("res://assets/icons/network_sync_manager.png")
class_name NetworkSyncComponent
extends Node
## Network sync component


@export var sync_rate: float = 0.05
@export var player: Player

var sync_timer: float = 0.0
var is_local: bool = false


func _ready() -> void:
	is_local = get_multiplayer_authority() == multiplayer.get_unique_id()
	
	if not is_local:
		await get_tree().process_frame
		_disable_input()


func _process(delta: float) -> void:
	if not is_local:
		return
	
	sync_timer += delta
	if sync_timer >= sync_rate:
		sync_timer = 0.0
		_sync_position()


func _sync_position() -> void:
	_rpc_sync_position.rpc(player.global_position, player.rotation, player.camera_pivot.rotation)


@rpc("any_peer", "call_remote", "reliable")
func _rpc_sync_position(pos: Vector3, rot: Vector3, camera_pivot_rot: Vector3) -> void:
	player.target_positiom = pos
	player.rotation = rot
	player.camera_pivot.rotation = camera_pivot_rot


func _disable_input() -> void:
	player.is_local = false
	#player.process_mode = Node.PROCESS_MODE_DISABLED
	#player.physics_interpolation_mode = Node.PHYSICS_INTERPOLATION_MODE_OFF
	
	player.camera.current = false
