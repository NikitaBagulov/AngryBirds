extends CanvasLayer

@export var score_levels: Dictionary = {1: 1000, 2: 2000, 3:4000}
signal restart_level
var animated_score
# Called when the node enters the scene tree for the first time.
func _ready():
	$Background.hide()
	set_process(false)

var shown_stars = []  # Список уровней звёзд, для которых звук уже проигран

func _process(delta):
	for level in score_levels.keys():
		print(animated_score, score_levels[level])
		if animated_score >= score_levels[level] and not level in shown_stars:
			# Играем звук только для новых звёзд
			var star_sound = $"/root/MusicManager/Star"
			if star_sound and star_sound.stream:
				star_sound.play()
				print("Звук звезды для уровня ", level)
			
			# Показываем звезду
			get_node("Background/Star" + str(level)).show()

			# Добавляем уровень звезды в список
			shown_stars.append(level)

	# Обновляем текст очков
	$Background/Label.text = str(int(animated_score))

func display(score):
	animated_score = 0
	set_process(true)
	$Background.show()
	var tween_score = create_tween()
	tween_score.set_trans(Tween.TRANS_LINEAR)
	tween_score.set_ease(Tween.EASE_IN)
	tween_score.tween_property(self, "animated_score", score, 0.5)


func _on_restart_button_pressed():
	emit_signal("restart_level")
