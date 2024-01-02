extends Control

var MultiplayerManager = Node.new()
var peer = EOSGMultiplayerPeer.new()

func _ready():
#setup MultiplayerManager
	var MultiplayerManagerScript = preload("res://scripts/multiplayer_manager.gd")
	MultiplayerManager.name = "MultiplayerManager"
	get_tree().root.add_child(MultiplayerManager)
	MultiplayerManager.set_script(MultiplayerManagerScript)

#connecting signals
	multiplayer.connected_to_server.connect(connection_success)
	peer.peer_connected.connect(player_connected)
	peer.peer_disconnected.connect(player_disconnected)
	#peer.peer_connection_established.connect(connection_success) #client-side
	peer.peer_connection_interrupted.connect(connection_fail) #client-side

#signal functions
func player_connected(id):
	pass

func player_disconnected(id):
	MultiplayerManager.players.erase(id)
	refresh_player_list()

func connection_success():
	if not multiplayer.is_server():
		send_player_data.rpc_id(1, $name.text, multiplayer.get_unique_id())

func connection_fail(error):
	print("failed connection" + str(error))

#send data to all players
@rpc("any_peer")
func send_player_data(p_name, id):
	if !MultiplayerManager.players.has(id):
		MultiplayerManager.players[id] = {
			"name" : p_name,
			"id" : id
		}
	refresh_player_list()
	if multiplayer.is_server():
		for i in MultiplayerManager.players:
			send_player_data.rpc(MultiplayerManager.players[i].name, i)

#start the game
@rpc("any_peer", "call_local")
func start_game():
	var scene = load("res://components/levels/world.tscn").instantiate()
	get_tree().root.add_child(scene)
	self.hide()

#when pressing the host button
func _on_host_button_down():
	if $name.text == "":
		return
	peer.create_server("teste")
	multiplayer.multiplayer_peer = peer
	send_player_data($name.text, multiplayer.get_unique_id())
	$start.show()
	$join.disabled = true
	$host_id.text = EOS_tick.login_id
	$host_id.show()

#when pressing the join button
func _on_join_button_down():
	if $name.text == "" or $code.text == "":
		return
	peer.create_client("teste", $code.text)
	multiplayer.multiplayer_peer = peer

#when pressing the start button
func _on_start_button_down():
	start_game.rpc()

@rpc("any_peer", "call_local")
func refresh_player_list():
	for i in $player_list.get_children():
		i.queue_free()

	for i in MultiplayerManager.players:
		var new_name = Label.new()
		new_name.text = str(MultiplayerManager.players[i].name)
		$player_list.add_child(new_name)
