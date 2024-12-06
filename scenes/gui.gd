extends CanvasLayer
@onready var score_progress = $MarginContainer/VBoxContainer/NinePatchRect/HBoxLeft/ScoreProgress
@onready var score_max_label = $MarginContainer/VBoxContainer/NinePatchRect/HBoxRight/ScoreMax
@onready var score_value_label = $MarginContainer/VBoxContainer/NinePatchRect/HBoxRight/ScoreValue
@onready var end_button = $MarginContainer/VBoxContainer/TextureButton

var animated_score = 0
signal end_game
# Called when the node enters the scene tree for the first time.
func _ready():
	end_button.self_modulate.a = 0
	end_button.disabled = true

func _process(delta):
	score_progress.value = animated_score
	score_value_label.text = str(int(animated_score))

func set_max_score(score_max):
	print(score_max)
	score_progress.max_value = score_max
	score_max_label.text = str(score_max)
	
func set_score(score):
	var tween_score = create_tween()
	tween_score.set_trans(Tween.TRANS_CUBIC)
	tween_score.set_ease(Tween.EASE_IN)
	tween_score.tween_property(self, "animated_score", score, 0.5)
	score_progress.value = score
	score_value_label.text = str(score)
	
func display_end_button():
	end_button.self_modulate.a = 1
	end_button.disabled = false


func _on_texture_button_pressed():
	emit_signal("end_game")
