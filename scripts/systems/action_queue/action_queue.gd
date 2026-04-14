class_name ActionQueue
extends Node
## Action queue


signal action_sent(sequence_id: int, action_type: String)
signal action_confirmed(sequence_id: int)
signal action_rejected(sequence_id: int, reason: String)


class PendingAction:
	var action: Action
	var on_success: Callable
	var on_failure: Callable
	var timestamp: float
	
	func _init(a: Action, ok: Callable, fail: Callable):
		action = a
		on_success = ok
		on_failure = fail
		timestamp = Time.get_unix_time_from_system()


var _pending: Dictionary[int, PendingAction] = {}
var _next_sequence_id: int = 1


@export var max_pending: int = 20
@export var timeout_seconds: float = 5.0

@onready var world: GameWorld = get_parent()



# Add action to queue
func submit(
		action: Action,
		on_success: Callable = Callable(),
		on_failure: Callable = Callable(),
		target_peer: int = 1
		) -> int:
	# If server then execute without any checks
	if multiplayer.is_server():
		var seq_id = _next_sequence_id
		_next_sequence_id += 1
		action.sequence_id = seq_id
		action.timestamp = Time.get_unix_time_from_system()
		
		_local_execute_and_respond(seq_id, action, on_success, on_failure)
		return seq_id
	
	# Check queue overflow
	if _pending.size() >= max_pending:
		push_warning("Action queue full (%d/%d)" % [_pending.size(), max_pending])
		if on_failure.is_valid():
			on_failure.call("queue_full")
		return -1
	
	# Create and send pending action to server
	var seq_id = _next_sequence_id
	_next_sequence_id += 1
	action.sequence_id = seq_id
	action.timestamp = Time.get_unix_time_from_system()
	
	var pending = PendingAction.new(action, on_success, on_failure)
	_pending[seq_id] = pending
	
	world.server_action_handler.rpc_receive_action.rpc_id(target_peer, action.to_dict())
	
	action_sent.emit(seq_id, action._get_action_type())
	
	return seq_id


# Execute on OK
# Call on_success from action and delete it
func confirm(sequence_id: int) -> void:
	if not _pending.has(sequence_id):
		push_warning("Confirm for unknown sequence_id: %d" % sequence_id)
		return
	
	var pending = _pending[sequence_id]
	_pending.erase(sequence_id)
	
	if pending.on_success.is_valid():
		pending.on_success.call(pending.action)
	
	action_confirmed.emit(sequence_id)


# Execute on error or timeout
# Call on_failure from action and delete it
func reject(sequence_id: int, reason: String) -> void:
	if not _pending.has(sequence_id):
		push_warning("Reject for unknown sequence_id: %d" % sequence_id)
		return
	
	var pending = _pending[sequence_id]
	_pending.erase(sequence_id)
	
	if pending.on_failure.is_valid():
		pending.on_failure.call(reason, pending.action)
	else:
		push_warning("Action %d rejected: %s" % [sequence_id, reason])
	
	action_rejected.emit(sequence_id, reason)


# Process queue
func _process(_delta: float) -> void:
	var now = Time.get_unix_time_from_system()
	var to_remove: Array[int] = []
	
	for seq_id in _pending:
		var pending = _pending[seq_id]
		if now - pending.timestamp > timeout_seconds:
			to_remove.append(seq_id)
	
	for seq_id in to_remove:
		reject(seq_id, "timeout")


# Host action execution
func _local_execute_and_respond(seq_id: int, action: Action, ok: Callable, fail: Callable) -> void:
	_pending[seq_id] = PendingAction.new(action, ok, fail)
	confirm(seq_id)
