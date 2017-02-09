extends Node

const UPDATE_TICK = 0.05
var _server = false
var _update_timer = 0

func _ready():
	# I really wish there was an easier way...
	if OS.get_cmdline_args().size() > 1:
		if OS.get_cmdline_args()[1] == "server":
			_server = true

	if _server:
		# Server will need to regularly send updates
		create_server()
		set_fixed_process(true)
	else:
		# Client will be STATIC, ie. you want to move them via tween! (and you could disable collisions too)
		create_client()
		get_node("Ball").set_mode(RigidBody2D.MODE_STATIC)
	pass

func _fixed_process(delta):
	if _server:
		_update_timer += delta
		# Server will send update every UPDATE_TICK (ideally 20/30 fps, ie. 0.05/0.03 sec)
		if _update_timer >= UPDATE_TICK:
			_update_timer -= UPDATE_TICK
			get_node("Ball").update_remote_state(UPDATE_TICK)

func create_client():
	set_network_mode(NETWORK_MODE_SLAVE)
	var client = NetworkedMultiplayerENet.new()
	client.create_client("127.0.0.1", 4321)
	get_tree().set_network_peer(client)

func create_server():
	set_network_mode(NETWORK_MODE_MASTER)
	var host = NetworkedMultiplayerENet.new()
	host.create_server(4321, 4)
	get_tree().set_network_peer(host)
