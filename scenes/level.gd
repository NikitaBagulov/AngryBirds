extends Node

var max_score = 0
var score = 0
var alive_birds
var game_ended = false

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
		
	alive_birds = get_tree().get_nodes_in_group("bird")
	
	var current_bird = change_bird()
	max_score -= current_bird.survive_points
	#current_bird.attach_to(slingshot)
	
	$GUI.set_max_score(max_score)
	
func on_bird_eliminated():
	var current_bird = change_bird()
	if ! current_bird :
		prepare_end()
	
func change_bird():
	if alive_birds.size() == 0:
		return null
	var current_bird = alive_birds.pop_front()
	current_bird.connect("eliminated", Callable(self, "on_bird_eliminated"))
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

func end_game():
	if game_ended:
		return
	game_ended = true
	while alive_birds.size() > 0:
		var bird = alive_birds.pop_front()
		score += bird.survive_points
		bird.explode()
	$GUI.set_score(score)

func _on_gui_end_game():
	print("EndGame")
	end_game()
