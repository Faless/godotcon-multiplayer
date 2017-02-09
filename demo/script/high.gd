extends RigidBody2D

# Server
var time = 0
func update_remote_state(tick):
	var state = []
	# Parse the game state
	# ... eg.
	state.append(get_pos())
	state.append(get_linear_velocity())
	# Send RPC, this requires that a node with the SAME path of this exists in the client
	time += 1
	rpc_unreliable("update_state", time, tick, state)

# Client
var last_time = 0
slave func update_state(time, tick, state):
	# ... (see next slide)
	# Handle wrap-around, see rfc1185 as reference
	if last_time >= time:
		# Out of order packet... drop
		return
	last_time = time
	# Handle state update here eg. tween this object
	get_node("Tween").stop_all()
	get_node("Tween").interpolate_method(self, "set_pos", 
										get_pos(), state[0], tick, Tween.TRANS_LINEAR, Tween.EASE_IN)
	get_node("Tween").interpolate_method(self, "set_linear_velocity", 
										get_linear_velocity(), state[1], tick, Tween.TRANS_LINEAR, Tween.EASE_IN)
	get_node("Tween").start()