extends Node

export var host: bool = false

var _discover_peer: PacketPeerUDP
var _game_peers: Dictionary
var _game_peer_objects: Array
var _heartbeat_timer: Timer = Timer.new()
var _id: String
var _lobby_peer: PacketPeerUDP
var _state: String = "HIDDEN"
var _started_connection = false

func close() -> void:
	_discover_peer.close()
	_lobby_peer.close()

	for _peer in _game_peers:
		_peer.close()

func get_host_address() -> int:
	for _peer in _game_peer_objects:
		if _peer.host:
			return _peer.address

	return 31400

func get_host_port() -> int:
	for _peer in _game_peer_objects:
		if _peer.host:
			return _peer.port

	return 31400

func _ready():
	_discover_peer = PacketPeerUDP.new()
	_lobby_peer = PacketPeerUDP.new()

	print(_discover_peer.connect_to_host("192.81.135.83", 31400))
	print(_lobby_peer.connect_to_host("192.81.135.83", 31401))

	_discover_peer.put_packet(JSON.print({"type": "DISCOVER"}).to_utf8())

	_heartbeat_timer.wait_time = 1

	_heartbeat_timer.connect("timeout", self, "_on_heartbeat_timer_timeout")

	add_child(_heartbeat_timer)

	_started_connection = true

func _on_heartbeat_timer_timeout():
	if _state == "DISCOVERED" || _state == "CONNECTED":
		_lobby_peer.put_packet(JSON.print({"type": "KEEPALIVE", "peerID": _id}).to_utf8())

func _on_ack_discover(discover_response):
	_id = discover_response.peer.id
	_state = "DISCOVERED"

	_lobby_peer.put_packet(JSON.print({"type": "JOIN", "host": host, "lobby": "ABCD", "peerID": _id}).to_utf8())
	_heartbeat_timer.start()

func _on_ack_join(join_response):
	_id = join_response.peer.id

	print("Joined lobby with id: {id} at {address}:{port}".format({"id": _id, "address": join_response.peer.address, "port": join_response.peer.port}))

func _on_join(join_message):
	print("Peer joined with ID: {id}".format({"id": join_message.peer.id}))
	
	if _state == "DISCOVERED":
		_state = "CONNECTED"
		_discover_peer.close()
		print(_discover_peer.listen(31400))
	
	_game_peer_objects.append(join_message.peer)

	var _new_peer: PacketPeerUDP = PacketPeerUDP.new()

	_game_peers[join_message.peer.id] = _new_peer

	print(_new_peer.connect_to_host(join_message.peer.address, join_message.peer.port))

	var _peer_punch_timer: Timer = Timer.new()

	_peer_punch_timer.connect("timeout", self, "_on_peer_punch_timer_timeout", [join_message.peer])

	add_child(_peer_punch_timer)

	_peer_punch_timer.start(1)

func _on_peer_punch_timer_timeout(peer):
	var _peer: PacketPeerUDP = _game_peers[peer.id]

	_peer.put_packet(JSON.print({"type": "PUNCH", "peerID": _id}).to_utf8())
	print(_discover_peer.is_listening())


func _process(_delta):
	if _started_connection && _lobby_peer.get_available_packet_count() > 0:
		print("received lobby message")
		var _message_json = JSON.parse(_lobby_peer.get_packet().get_string_from_utf8()).result

		match _message_json.type:
			"ACK":
				print("message ackd")

			"ACK_JOIN":
				_on_ack_join(_message_json)

			"JOIN":
				_on_join(_message_json)

			"PUNCH":
				# Not receiving this from clients on the same network? :hopeful:
				print("Received punch from peer in lobby: {id}".format({"id": _message_json.peerID}))

	if _started_connection && _discover_peer.get_available_packet_count() > 0:
		var _message_json = JSON.parse(_discover_peer.get_packet().get_string_from_utf8()).result

		match _message_json.type:
			"ACK_DISCOVER":
				_on_ack_discover(_message_json)

			"PUNCH":
				# Not receiving this from clients on the same network? :hopeful:
				print("Received punch from peer in discover: {id}".format({"id": _message_json.peerID}))

	for _game_peer_id in _game_peers:
		if _game_peers[_game_peer_id].get_available_packet_count() > 0:
			var _message_json = JSON.parse(_game_peers[_game_peer_id].get_packet().get_string_from_utf8()).result

			match _message_json.type:
				"PUNCH":
					# Not receiving this from clients on the same network? :hopeful:
					print("Received punch from peer in game_peer: {id}".format({"id": _message_json.peerID}))
