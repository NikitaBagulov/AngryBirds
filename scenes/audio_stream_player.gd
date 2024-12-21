extends AudioStreamPlayer


# Called when the node enters the scene tree for the first time.
func _ready():
	var music_player = $BackgroundMusic  # Получаем ссылку на AudioStreamPlayer
	music_player.play()  # Запускаем музыку
