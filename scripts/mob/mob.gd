class_name Mob
extends StaticBody3D
## Moveable object


signal landed(land_velocity: Vector3)

@export var mob_stats: MobStats = preload("res://resourses/mob/default_mob_stats.tres")
@export var mob_aabb := AABB(
	Vector3(-0.4, -0.9, -0.4),
	Vector3(0.8, 1.8, 0.8)
)

var move_dir: Vector3
var knockback_velocity: Vector3
var box_mover := VoxelBoxMover.new()
var voxel_terrain: VoxelTerrain
var is_on_floor: bool = false
var is_jumping: bool = false

var velocity := Vector3.ZERO
var motion := Vector3.ZERO
var prev_motion := Vector3.ZERO

var _is_gravity_enabled: bool = true

func _ready() -> void:
	box_mover.set_collision_mask(1)
	box_mover.set_step_climbing_enabled(true)
	box_mover.set_max_step_height(0.5)


func _physics_process(delta: float) -> void:
	mob_process(delta)


func mob_process(delta: float) -> void:
	if not mob_stats:
		return
	motion = velocity * delta
	prev_motion = motion
	
	if is_on_floor:
		velocity.y = 0
	
	_apply_gravity(delta)
	_apply_knockback(delta)
	if is_on_floor:
		process_movement(delta)
	else:
		process_air_movement(delta)
	
	move_and_slide()
	update_state(delta)


func _apply_gravity(delta: float) -> void:
	if _is_gravity_enabled:
		velocity.y -= 20.0 * mob_stats.gravity_multiplier * delta


func _apply_knockback(delta: float) -> void:
	if knockback_velocity.length() > 0.1:
		velocity.x += knockback_velocity.x * delta
		velocity.y += knockback_velocity.y * delta
		velocity.z += knockback_velocity.z * delta
		knockback_velocity = knockback_velocity.lerp(Vector3.ZERO, mob_stats.knockback_decay * delta)


func process_movement(delta: float) -> void:
	if move_dir:
		velocity.x = lerpf(velocity.x, move_dir.x * mob_stats.speed,
				mob_stats.acceleration * delta)
		velocity.z = lerpf(velocity.z, move_dir.z * mob_stats.speed,
				mob_stats.acceleration * delta)
	else:
		velocity.x = lerpf(velocity.x, 0, mob_stats.friction * delta)
		velocity.z = lerpf(velocity.z, 0, mob_stats.friction * delta)


func process_air_movement(delta: float) -> void:
	if move_dir:
		velocity.x = lerpf(velocity.x, move_dir.x * mob_stats.speed,
				mob_stats.acceleration/mob_stats.less_control_in_air * delta)
		velocity.z = lerpf(velocity.z, move_dir.z * mob_stats.speed,
				mob_stats.acceleration/mob_stats.less_control_in_air * delta)
	else:
		velocity.x = lerpf(velocity.x, 0,
				mob_stats.friction/mob_stats.less_control_in_air * delta)
		velocity.z = lerpf(velocity.z, 0,
				mob_stats.friction/mob_stats.less_control_in_air * delta)


func jump() -> void:
	if is_on_floor:
		is_jumping = true
		is_on_floor = false
		velocity.y = mob_stats.jump_velocity


func set_knockback(force: Vector3) -> void:
	knockback_velocity = force * (1.0 - mob_stats.knockback_resistance) \
			* mob_stats.knockback_force_multiplier


func reset_physics() -> void:
	velocity = Vector3.ZERO
	knockback_velocity = Vector3.ZERO
	move_dir = Vector3.ZERO


func move_and_slide() -> void:
	motion = box_mover.get_motion(global_position, motion, mob_aabb, voxel_terrain)
	global_translate(motion)


func update_state(delta: float) -> void:
	if absf(motion.y) < 0.001 and prev_motion.y < -0.001:
		landed.emit(prev_motion)
		is_jumping = false
		is_on_floor = true
	
	if box_mover.has_stepped_up():
		is_on_floor = true
	elif absf(motion.y) > 0.001:
		is_on_floor = false
	if motion.y > 0.001:
		is_jumping = false


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
				velocity.y = 0
				is_on_floor = true


func enable_gravity() -> void:
	_is_gravity_enabled = true


func disable_gravity() -> void:
	_is_gravity_enabled = false
