extends Sprite2D


func _ready():
	$AnimationPlayer.play("default")
	await $AnimationPlayer.animation_finished
	queue_free()
