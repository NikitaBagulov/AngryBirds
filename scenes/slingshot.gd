extends Node2D

@export var TRAJECTORY_SPOT_COUNT = 20
@export var TRAJECTORY_TIME_STEP = 0.7
@export var STRENGTH:int = 2
@export var SPOT_SCENE: PackedScene

var bird
var BirdScript = preload("res://scenes/birds/bird.gd")

func _ready():
	$Trajectory.position = $LaunchPoint.position

func _process(delta):
	for spot in $Trajectory.get_children():
		spot.queue_free()
	update_elastic($ElasticBack)
	update_elastic($ElasticFront)
	var impulse = get_impulse() 
	if self.bird and self.bird.state == BirdScript.State.STATE_DRAGGED and impulse.x > 0:
		draw_trajectory_for_impulse(impulse)
	
func update_elastic(elastic):
	var attach_pos = self.bird.get_node("AttachPoint").get_global_position() if self.bird else $LaunchPoint.get_global_position()
	#print(attach_pos)
	var diff_pos = attach_pos - elastic.get_node("FixPoint").get_global_position()
	var middle = diff_pos/2
	var sprite = elastic.get_node("Sprite2D")
	sprite.position = middle
	sprite.scale.x = - middle.length() * 0.01
	sprite.rotation = middle.angle()

func get_impulse():
	if ! self.bird:
		return null
	return ($LaunchPoint.global_position - self.bird.global_position) / STRENGTH

func draw_trajectory_for_impulse(impulse):
	var gravity = ProjectSettings.get("physics/2d/default_gravity") / 1000
	print(gravity)
	for i in range(TRAJECTORY_SPOT_COUNT):
		var t = i * TRAJECTORY_TIME_STEP
		var x = impulse.x * t 
		var y = 0.5 * gravity * t * t + impulse.y * t 
		var spot_traj = Vector2(x, y) 
		draw_spot(spot_traj)

func draw_spot(position):
	var spot = SPOT_SCENE.instantiate()
	spot.position = position
	$Trajectory.add_child(spot)

func attach_bird(bird):
	self.bird = bird
	
func dettach_bird():
	self.bird = null
