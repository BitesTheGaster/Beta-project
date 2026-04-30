class_name Player
extends Mob


var queue: ActionQueue
var voxel_tool: VoxelTool
var sit_on: Mob

# TEMP
var current_block: int = 1

@onready var camera_pivot_x: Node3D = %CameraPivotX
@onready var camera_pivot_y: Node3D = %CameraPivotY
@onready var health: HealthComponent = %HealthComponent
@onready var raycast: RayCast3D = %Raycast
@onready var camera_spring_arm: SpringArm3D = %CameraSpringArm
@onready var body: MeshInstance3D = %Body


func _ready() -> void:
	#stats.max_health = health.max_health
	health.health_changed.emit(health.current_health, health.max_health)


func _physics_process(delta: float) -> void:
	if sit_on:
		if is_jumping or not is_on_floor:
			sit_on = null
			enable_gravity()
		else:
			position = sit_on.position
			position.y += sit_on.mob_aabb.size.y
	mob_process(delta)


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("attack"):
		raycast.force_raycast_update()
		var target = raycast.get_collider()
		if target is RemotePlayer:
			_submit_damage_action(target)
		else:
			_submit_block_action(0)
	if event.is_action_pressed("use"):
		_submit_block_action(current_block)


func _unhandled_key_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		else:
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	
	if event.is_action_pressed("slot1"):
		current_block = 1
	if event.is_action_pressed("slot2"):
		current_block = 2
	if event.is_action_pressed("slot3"):
		current_block = 3


func get_camera_rotation() -> Vector3:
	return Vector3(
		camera_pivot_x.rotation.x,
		camera_pivot_y.rotation.y,
		0
	)


func _on_player_damaged(source: Vector3) -> void:
	var knockback: Vector3 = (global_position-source)*100
	set_knockback(knockback)


func interact_with_mob(target: Mob) -> void:
	var target_aabb := target.mob_aabb
	target_aabb.position += target.global_position
	var my_aabb := mob_aabb
	my_aabb.position += global_position
	
	
	if my_aabb.intersects(target_aabb):
		var to_target = global_position - target.global_position
		#to_target.y = 0
		if to_target.length() > 0.01:
			if absf(to_target.y) < 1.0:
				to_target = to_target.normalized()
				var push_strength = 0.25
				velocity.x += to_target.x * push_strength
				velocity.z += to_target.z * push_strength
			elif not is_jumping and to_target.y > 0:
				if Input.is_action_pressed("use"):
					sit_on = target
					disable_gravity()
				velocity.y = 0
				is_on_floor = true


func _submit_block_action(block_id: int) -> void:
	if not queue:
		return
	
	var hit = _get_pointed_voxel()
	if not hit:
		return
	
	var target_pos = hit.position if block_id == 0 else hit.previous_position
	
	var action = PlaceBlockAction.new()
	action.position = target_pos
	action.block_id = block_id
	action.sender_id = multiplayer.get_unique_id()
	
	queue.submit(
		action,
		Callable(self, "_on_block_action_success"),
		Callable(self, "_on_block_action_failure")
	)


func _on_block_action_success(a: PlaceBlockAction) -> void:
	pass


func _on_block_action_failure(reason: String, a: PlaceBlockAction) -> void:
	print("Block not placed at ", a.position,": ", reason)


func _get_pointed_voxel() -> VoxelRaycastResult:
	if not voxel_tool:
		return null
	
	var origin := camera_pivot_x.get_global_transform().origin
	var forward := -camera_pivot_x.get_global_transform().basis.z.normalized()
	return voxel_tool.raycast(origin, forward, 5)


func _submit_damage_action(target: RemotePlayer) -> void:
	if not queue: return
	
	var action = DamageAction.new()
	action.target_id = target.player_id
	action.damage = 10.0
	action.source_position = camera_pivot_x.global_position
	action.sender_id = multiplayer.get_unique_id()
	
	queue.submit(
		action,
		Callable(self, "_on_damage_success"),
		Callable(self, "_on_damage_failure")
	)


func _on_damage_success(a: DamageAction):
	pass


func _on_damage_failure(reason: String, a: DamageAction):
	print("Player ", a.target_id, " not damaged: ", reason)
