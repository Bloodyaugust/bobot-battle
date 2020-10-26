extends Node

signal client_created
signal server_created

export var ip_address: String
export var port: int
export var max_clients: int


func create_client():
	var peer := NetworkedMultiplayerENet.new()

	peer.create_client(ip_address, port)
	get_tree().set_network_peer(peer)
	emit_signal("client_created")


func create_server():
	var peer := NetworkedMultiplayerENet.new()

	peer.create_server(port, max_clients)
	get_tree().set_network_peer(peer)
	emit_signal("server_created")


func _on_network_peer_connected(id: int):
	print("Client ID: {id} connected".format({"id": id}))


func _ready():
	get_tree().connect("network_peer_connected", self, "_on_network_peer_connected")
