extends Node

signal client_created
signal server_created

export var address: String
export var port: int
export var max_clients: int

var _peer: NetworkedMultiplayerENet = NetworkedMultiplayerENet.new()


func create_client(address, port):
	_peer.create_client(address, port)
	get_tree().set_network_peer(_peer)
	emit_signal("client_created")


func create_server(port):
	_peer.create_server(port, max_clients)
	get_tree().set_network_peer(_peer)
	emit_signal("server_created")


func _on_network_peer_connected(id: int):
	print("Client ID: {id} connected from {ip}:{port}".format({"id": id, "ip": _peer.get_peer_address(id), "port": _peer.get_peer_port(id)}))


func _ready():
	get_tree().connect("network_peer_connected", self, "_on_network_peer_connected")

	if OS.has_feature("Server"):
		create_server(31400)
