extends Node

signal client_created
signal server_created

export var ip_address: String
export var port: int
export var max_clients: int

var peer: NetworkedMultiplayerENet


func create_client():
	peer = NetworkedMultiplayerENet.new()

	peer.create_client(ip_address, port)
	get_tree().set_network_peer(peer)
	emit_signal("client_created")


func create_server():
	peer = NetworkedMultiplayerENet.new()

	peer.create_server(port, max_clients)
	get_tree().set_network_peer(peer)
	emit_signal("server_created")


func _on_network_peer_connected(id: int):
	print("Client ID: {id} connected from {ip}:{port}".format({"id": id, "ip": peer.get_peer_address(id), "port": peer.get_peer_port(id)}))
	peer.put_var("test")


func _ready():
	get_tree().connect("network_peer_connected", self, "_on_network_peer_connected")

	if OS.has_feature("Server"):
		create_server()
