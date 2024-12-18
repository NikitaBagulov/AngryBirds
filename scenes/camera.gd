extends Camera2D

var drag_cam = false
var old_mouse_pos
@export var CAMERA_SPEED: int = 2
@export_range(0.5, 2) var zoom_min = 0.5
@export_range(2, 20) var zoom_max = 2
@export var ZOOM_SPEED: int = 10

func _ready():
	pass

func _process(delta):
	var mouse_pos = get_global_mouse_position()
	
	if Input.is_action_just_pressed("drag_cam"):
		drag_cam = true
		old_mouse_pos = mouse_pos
	
	if Input.is_action_just_released("drag_cam"):
		drag_cam = false
		
	if drag_cam:
		var mouse_move = old_mouse_pos - mouse_pos
		position = clamp_position(position + mouse_move)
		old_mouse_pos = mouse_pos
		
func clamp_position(pos):
	var viewport_radius = get_viewport_rect().size / 2 * zoom
	
	pos.x = clamp(pos.x, limit_left + viewport_radius.x, limit_right - viewport_radius.x)
	pos.y = clamp(pos.y, limit_top + viewport_radius.y, limit_bottom - viewport_radius.y)
	
	return pos
	
func _input(event):
	var z = zoom.x
	if event.is_action("zoom_in"):
		z -= 0.01 * ZOOM_SPEED
	if event.is_action("zoom_out"):
		z += 0.01 * ZOOM_SPEED
	z = clamp(z, zoom_min, zoom_max)
	
	zoom = Vector2(z, z)
