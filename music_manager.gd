extends Node


# Called when the node enters the scene tree for the first time.
func _ready():
	var music_player = $BackgroundMusic  # Получаем ссылку на AudioStreamPlayer
	music_player.play() 


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
