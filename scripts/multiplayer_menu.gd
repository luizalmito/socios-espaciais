extends Control

@export var address = "127.0.0.1"
@export var port = 8080
var peer

func _ready():
	multiplayer.peer_connected.connect(player_connected)
	multiplayer.peer_disconnected.connect(player_disconnected)
	multiplayer.connected_to_server.connect(connection_success)
	multiplayer.connection_failed.connect(connection_fail)

func player_connected(id):
	pass

func player_disconnected(id):
	MultiplayerManager.players.erase(id)
	player_list()

func connection_success():
	send_player_data.rpc_id(1, $name.text, multiplayer.get_unique_id())

func connection_fail():
	print("failed connection")

@rpc("any_peer")
func send_player_data(p_name, id):
	if !MultiplayerManager.players.has(id):
		MultiplayerManager.players[id] = {
			"name" : p_name,
			"id" : id
		}
	player_list()
	if multiplayer.is_server():
		for i in MultiplayerManager.players:
			send_player_data.rpc(MultiplayerManager.players[i].name, i)

@rpc("any_peer", "call_local")
func start_game():
	var scene = load("res://scenes/world.tscn").instantiate()
	get_tree().root.add_child(scene)
	self.hide()

func _on_host_button_down():
	peer = ENetMultiplayerPeer.new()
	var error = peer.create_server(port)
	if error != OK:
		print("cannot host: " + str(error))
		return
	multiplayer.set_multiplayer_peer(peer)
	send_player_data($name.text, multiplayer.get_unique_id())
	
	$start.show()
	$join.disabled = true
	print("hosting")

func _on_join_button_down():
	peer = ENetMultiplayerPeer.new()
	peer.create_client(address, port)
	multiplayer.set_multiplayer_peer(peer)
	$join.disabled = true

func _on_start_button_down():
	start_game.rpc()

@rpc("any_peer")
func player_list():
	for i in $player_list.get_children():
		i.queue_free()

	for i in MultiplayerManager.players:
		var new_name = Label.new()
		new_name.text = str(MultiplayerManager.players[i].id)
		$player_list.add_child(new_name)
