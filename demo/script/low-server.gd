extends Node

var _clients = []
var _udp = PacketPeerUDP.new()

func _ready():
	_udp.listen(4321)
	set_process(true)

func _process(delta):
	var msgs = []

	while _udp.get_available_packet_count() > 0:
		var pkt = _udp.get_var() # or get_packet()
		var ip = _udp.get_packet_ip()
		var port = _udp.get_packet_port()
		if _clients.find(ip + ":" + str(port)) == -1:
			# New client
			_clients.append(ip + ":" + str(port))
			# Prepare message to be broadcasted
		msgs.append(ip + ":" + str(port) + "-" + str(pkt))
	# Broadcast messages
	for c in _clients:
		var splitted = c.split(":")
		_udp.set_send_address(splitted[0], int(splitted[1]))
		for msg in msgs:
			_udp.put_var(msg)
