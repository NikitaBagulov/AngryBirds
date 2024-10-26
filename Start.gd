extends TextureButton

func _ready():
	connect("pressed", Callable(self, "_on_button_pressed"))

func _on_button_pressed():
		get_tree().change_scene_to_file("res://scenes/Level.tscn")
