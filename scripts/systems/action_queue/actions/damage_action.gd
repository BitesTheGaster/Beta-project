class_name DamageAction
extends Action


@export var max_distance: float = 5.0
@export var min_damage_interval: float = 0.01

var target_id: int
var damage: float
var source_position: Vector3


func to_dict() -> Dictionary:
	var dict = super.to_dict()
	dict["target_id"] = target_id
	dict["damage"] = damage
	dict["source_position"] = source_position
	return dict


static func from_dict(data: Dictionary) -> DamageAction:
	var action = DamageAction.new()
	action.sequence_id = data.get("seq", 0)
	action.timestamp = data.get("ts", 0.0)
	action.sender_id = data.get("sender", 0)
	action.target_id = data.get("target_id", 0)
	action.damage = data.get("damage", 10.0)
	action.source_position = data.get("source_position", Vector3.ZERO)
	return action


func validate(context: Dictionary) -> ValidationResult:
	# Distance check
	var sender_pos: Vector3 = context.get("sender_position", Vector3.ZERO)
	var target_pos: Vector3 = context.get("target_position", Vector3.ZERO)
	if sender_pos.distance_to(target_pos) > max_distance:
		return ValidationResult.invalid("too_far")
	
	# Is target alive
	var target_health = context.get("target_health", -1)
	if target_health <= 0:
		return ValidationResult.invalid("target_dead")
	
	# Spam protection
	var last_damage_time = context.get("last_damage_time", 0.0)
	if timestamp - last_damage_time < min_damage_interval:
		return ValidationResult.invalid("too_fast")
	
	return ValidationResult.ok()


func execute(world: GameWorld) -> void:
	if not world.spawned_players.keys().has(target_id) and target_id != 1:
		return
	
	world.players_container.request_damage.rpc(target_id, damage, source_position)
