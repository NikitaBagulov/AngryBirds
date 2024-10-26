extends ParallaxBackground

@export var SPEED: int = 100
@onready var camera = get_viewport().get_camera_2d()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	scroll_offset.x -= SPEED * delta
	#if camera:
		### Устанавливаем позицию параллакса в зависимости от камеры, но зум игнорируем
		#scale = Vector2(1 / camera.zoom.x, 1 / camera.zoom.y)
