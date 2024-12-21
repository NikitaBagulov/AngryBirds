extends Node

var max_score = 0
var score = 0
var unlaunched_birds
var game_ended = false

var tracked_bird = null
var camera_offset = Vector2(1000, 1200)  # Смещение камеры вниз

func track_bird(bird):
	tracked_bird = bird

func _ready():
	#var bird = $Birds/Bird  # Получаем ссылку на узел Bird
	  # Получаем ссылку на узел Slingshot
	#
	#if bird and slingshot:  # Проверяем, что оба узла существуют
		#bird.attach_to(slingshot)  # Вызываем метод attach_to
	#else:
		#print("Ошибка: Bird или Slingshot не найдены.")
		
	for damageble in get_tree().get_nodes_in_group("damageble"):
		damageble.connect("exploded", Callable(self, "on_damageble_exploded"))
		max_score += max(damageble.destroy_points, damageble.survive_points)
		
	unlaunched_birds = get_tree().get_nodes_in_group("bird")
	
	var current_bird = change_bird()
	max_score -= current_bird.survive_points
	#current_bird.attach_to(slingshot)
	
	$GUI.set_max_score(max_score)
	
func on_bird_eliminated():
	var current_bird = change_bird()
	if !is_instance_valid(current_bird):
		prepare_end()
	else:
		$Camera.position = $Slingshot.position
		tracked_bird = null
	
func on_bird_launched(bird):
	unlaunched_birds.pop_front()
	track_bird(bird)
	
func change_bird():
	if unlaunched_birds.size() == 0:
		return null
	var current_bird = unlaunched_birds[0]
	current_bird.connect("eliminated", Callable(self, "on_bird_eliminated"))
	current_bird.connect("launched", Callable(self, "on_bird_launched"))
	current_bird.attach_to($Slingshot)
	
	return current_bird

func on_damageble_exploded(damageble):
	score += damageble.destroy_points
	$GUI.set_score(score)
	await get_tree().process_frame
	var enemies = get_tree().get_nodes_in_group("enemy")
	if enemies.size() == 0:
		prepare_end()

func prepare_end():
	$GUI.display_end_button()

func _physics_process(delta):
	if tracked_bird and is_instance_valid(tracked_bird):
		var target_position = tracked_bird.position + camera_offset
		# Плавное следование камеры
		$Camera.position = lerp($Camera.position, target_position, 0.1)

func end_game():
	if game_ended:
		return
	game_ended = true
	if get_tree().get_nodes_in_group("enemy").size() > 0:
		$GameOver.display()
		return
	while unlaunched_birds.size() > 0:
		var bird = unlaunched_birds.pop_front()
		score += bird.survive_points
		bird.explode()
	$GUI.set_score(score)
	await get_tree().create_timer(2).timeout
	$EndLevel.display(score)

func restart_level():
	get_tree().reload_current_scene()

func _on_gui_end_game():
	print("EndGame")
	end_game()
	


func _on_end_level_restart_level():
	restart_level()


func _on_game_over_restart_level():
	restart_level()
