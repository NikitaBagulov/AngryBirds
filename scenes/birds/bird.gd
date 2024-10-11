extends "res://scenes/damageable.gd"


enum State {
	STATE_IDLE,
	STATE_TRANSFERED,
	STATE_ATTACHED,
	STATE_DRAGGED,
	STATE_RELEASED,
	STATE_LAUNCHED
}

var state: State = State.STATE_IDLE
var slingshot = null
var impulse = null

@export_range(1, 10) var TRANSFER_SPEED = 5

func _integrate_forces(st) -> void:
	if st.get_contact_count() > 0 and state == State.STATE_LAUNCHED:
		self.state = State.STATE_IDLE
	var launch_pos = slingshot.get_node("LaunchPoint").get_global_position()
	var diff_pos = launch_pos - get_global_position()
	if Input.is_action_just_released("touch"):
		if self.state == State.STATE_DRAGGED:
			self.impulse = diff_pos * 0.2
			self.state = State.STATE_RELEASED if impulse.x > 0 else State.STATE_ATTACHED
	var lv = st.get_linear_velocity()
	var av = st.get_angular_velocity()
	var delta = 1 / st.get_step()
	

	# implement states
	match self.state:
		State.STATE_TRANSFERED:
			if diff_pos.length() < TRANSFER_SPEED:
				lv = diff_pos * delta
				self.state = State.STATE_ATTACHED
			else:
				lv = diff_pos.normalized() * TRANSFER_SPEED * delta
		State.STATE_ATTACHED:
			lv = diff_pos * delta * 0.3
			av = - rotation * delta
		State.STATE_DRAGGED:
			var player_force = get_global_mouse_position() - launch_pos
			var angle = diff_pos.angle()
			av = (angle - rotation) * delta
			if angle < -1.2 and angle > -2:
				player_force = player_force.limit_length(10)
			else:
				player_force = player_force.limit_length(100)
			lv = (player_force + diff_pos) * delta * 0.3
		State.STATE_RELEASED:
			if diff_pos.length() < impulse.length():
				self.state = State.STATE_LAUNCHED
			else:
				lv = impulse * delta
		State.STATE_LAUNCHED:
			av = (lv.angle() - rotation) * delta

	st.set_linear_velocity(lv)
	st.set_angular_velocity(av)
	
func _input_event(viewport, event, shape_idx):
	
	if event.is_action_pressed("touch"):
		self.state = State.STATE_DRAGGED	
	
func attach_to(slingshot):
	self.slingshot = slingshot
	self.state = State.STATE_TRANSFERED
