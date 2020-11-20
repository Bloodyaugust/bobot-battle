extends Node

signal client_created
signal server_created

export var address: String
export var port: int
export var max_clients: int

onready var _host_info_controller: Node = get_tree().get_root().find_node("HostInfo", true, false)

var _localhost_games: Dictionary = {}
var _localhost_peer: PacketPeerUDP = PacketPeerUDP.new()
var _peer: NetworkedMultiplayerENet = NetworkedMultiplayerENet.new()
var _time_to_broadcast: float = 0


func create_client(address, port):
	_peer.create_client(address, port)
	get_tree().set_network_peer(_peer)
	emit_signal("client_created")

	_localhost_peer.listen(ClientConstants.LOCALHOST_PORT)


func create_server(port):
	_peer.create_server(port, max_clients)
	get_tree().set_network_peer(_peer)
	emit_signal("server_created")

	_localhost_peer.set_broadcast_enabled(true)
	_localhost_peer.set_dest_address("255.255.255.255", ClientConstants.LOCALHOST_PORT)


func get_localhost_game_address(name: String) -> String:
	if _localhost_games.has(name):
		return _localhost_games[name]

	return ""

func _on_network_peer_connected(id: int):
	print("Client ID: {id} connected from {ip}:{port}".format({"id": id, "ip": _peer.get_peer_address(id), "port": _peer.get_peer_port(id)}))


func _process(delta):
	if _localhost_peer.is_listening() && _localhost_peer.get_available_packet_count() > 0:
		var _host_ip = _localhost_peer.get_packet_ip()
		var _packet_bytes = _localhost_peer.get_packet()

		var _message_json = parse_json(_packet_bytes.get_string_from_ascii())

		_localhost_games[_message_json.name] = _host_ip

	if get_tree().has_network_peer() && get_tree().is_network_server():
		_time_to_broadcast -= delta

		if _time_to_broadcast <= 0:
			_time_to_broadcast = ClientConstants.LOCALHOST_BROADCAST_INTERVAL

			_localhost_peer.put_packet(to_json(_host_info_controller.get_localhost_info()).to_ascii())

func _ready():
	get_tree().connect("network_peer_connected", self, "_on_network_peer_connected")

	if OS.has_feature("Server"):
		create_server(31400)
