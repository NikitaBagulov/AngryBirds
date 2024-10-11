extends Node


func _ready():
	var bird = $Birds/Bird  # Получаем ссылку на узел Bird
	var slingshot = $Slingshot  # Получаем ссылку на узел Slingshot
	
	if bird and slingshot:  # Проверяем, что оба узла существуют
		bird.attach_to(slingshot)  # Вызываем метод attach_to
	else:
		print("Ошибка: Bird или Slingshot не найдены.")
