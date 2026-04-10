class_name Mob
extends CharacterBody3D
## Moveable object


@export var mob_stats: MobStats = preload("res://resourses/mob/default_mob_stats.tres")

var move_dir: Vector3
var knockback_velocity: Vector3


func _physics_process(delta: float) -> void:
	if not mob_stats:
		return
	
	_apply_gravity(delta)
	_apply_knockback(delta)
	if is_on_floor():
		process_movement(delta)
	else:
		process_air_movement(delta)
	
	move_and_slide()


func _apply_gravity(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * mob_stats.gravity_multiplier * delta


func _apply_knockback(delta: float) -> void:
	if knockback_velocity.length() > 0.1:
		velocity.x += knockback_velocity.x * delta
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
	if is_on_floor():
		velocity.y = mob_stats.jump_velocity


func set_knockback(force: Vector3) -> void:
	knockback_velocity = force * (1.0 - mob_stats.knockback_resistance) \
			* mob_stats.knockback_force_multiplier


func reset_physics() -> void:
	velocity = Vector3.ZERO
	knockback_velocity = Vector3.ZERO
	move_dir = Vector3.ZERO
