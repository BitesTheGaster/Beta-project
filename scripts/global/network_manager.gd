extends Node


signal connection_failed()
signal connection_succeeded()
signal player_connected(id: int)
signal player_disconnected(id: int)

const DEFAULT_PORT: int = 7777
const MAX_PLAYERS: int = 8

var is_server: bool = false
var is_client: bool = false


func _ready() -> void:
	multiplayer.peer_connected.connect(_on_peer_connected)
	multiplayer.peer_disconnected.connect(_on_peer_disconnected)
	multiplayer.connected_to_server.connect(_on_connected_to_server)
	multiplayer.connection_failed.connect(_on_connection_failed)


func host_game(port: int = DEFAULT_PORT) -> Error:
	var peer = ENetMultiplayerPeer.new()
	var error = peer.create_server(port, MAX_PLAYERS)
	
	if error != OK:
		connection_failed.emit()
		return error
	
	multiplayer.multiplayer_peer = peer
	is_server = true
	is_client = false
	
	print("[Network] Hosting on port %d" % port)
	connection_succeeded.emit()
	return OK


func join_game(ip: String, port: int = DEFAULT_PORT) -> Error:
	var peer = ENetMultiplayerPeer.new()
	var error = peer.create_client(ip, port)
	
	if error != OK:
		connection_failed.emit()
		return error
	
	multiplayer.multiplayer_peer = peer
	is_server = false
	is_client = true
	
	print("[Network] Joining %s:%d" % [ip, port])
	return OK


func disconnect_from_game() -> void:
	if multiplayer.multiplayer_peer:
		multiplayer.multiplayer_peer.close()
		multiplayer.multiplayer_peer = null
	
	is_server = false
	is_client = false
	print("[Network] Disconnected")


func _on_peer_connected(id: int) -> void:
	print("[Network] Player connected: %d" % id)
	player_connected.emit(id)


func _on_peer_disconnected(id: int) -> void:
	print("[Network] Player disconnected: %d" % id)
	player_disconnected.emit(id)


func _on_connected_to_server() -> void:
	print("[Network] Connected to server!")
	connection_succeeded.emit()


func _on_connection_failed() -> void:
	print("[Network] Connection failed!")
	connection_failed.emit()
