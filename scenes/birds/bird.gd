extends "res://scenes/damageable.gd"

# Перечисление состояний объекта в слинге
enum State {
	STATE_IDLE,      # Объект находится в состоянии покоя
	STATE_TRANSFERED,# Объект переносится к точке запуска
	STATE_ATTACHED,  # Объект прикреплен к рогатке
	STATE_DRAGGED,   # Объект тянется игроком
	STATE_RELEASED,  # Объект выпущен
	STATE_LAUNCHED   # Объект запущен
}

# Переменная для отслеживания состояния объекта
var state: State = State.STATE_IDLE

# Ссылка на рогатку (slingshot)
var slingshot = null

# Импульс для запуска объекта
var impulse = null

# Скорость переноса объекта к точке запуска
@export_range(1, 10) var TRANSFER_SPEED = 5

# Коэффициенты для расчета импульса и других физических параметров
const IMPULSE_FACTOR = 0.2
const ATTACHED_SPEED_FACTOR = 0.3
const DRAGGED_LIMIT_ANGLE_1 = -1.2
const DRAGGED_LIMIT_ANGLE_2 = -2.0
const DRAGGED_FORCE_LIMIT_1 = 10
const DRAGGED_FORCE_LIMIT_2 = 100

# Функция физической интеграции сил, которая управляет движением объекта
func _integrate_forces(st) -> void:
	# Проверяем количество контактов и возвращаем объект в состояние покоя при столкновении
	if st.get_contact_count() > 0 and state == State.STATE_LAUNCHED:
		self.state = State.STATE_IDLE
	
	# Получаем глобальную позицию точки запуска рогатки
	var launch_pos = slingshot.get_node("LaunchPoint").get_global_position()
	var diff_pos = launch_pos - get_global_position()  # Вычисляем разницу между текущей позицией объекта и точкой запуска

	# Проверка на отпускание объекта игроком
	if Input.is_action_just_released("touch"):
		if self.state == State.STATE_DRAGGED:
			# Расчет импульса на основе разницы в позициях
			self.impulse = diff_pos * IMPULSE_FACTOR
			# Если импульс положителен, объект отпускается, иначе остается прикрепленным
			self.state = State.STATE_RELEASED if impulse.x > 0 else State.STATE_ATTACHED
	
	# Получаем текущие значения линейной и угловой скорости объекта
	var lv = st.get_linear_velocity()
	var av = st.get_angular_velocity()
	var delta = 1 / st.get_step()  # Время на шаг физической симуляции
	
	# Реализация состояний
	match self.state:
		# Состояние переноса объекта к точке запуска
		State.STATE_TRANSFERED:
			# Если объект почти достиг точки запуска, переводим его в состояние прикрепления
			if diff_pos.length() < TRANSFER_SPEED:
				lv = diff_pos * delta
				self.state = State.STATE_ATTACHED
			else:
				# Перемещаем объект к точке запуска с ограниченной скоростью
				lv = diff_pos.normalized() * TRANSFER_SPEED * delta
		
		# Состояние прикрепления к рогатке
		State.STATE_ATTACHED:
			# Объект медленно удерживается у точки запуска
			lv = diff_pos * delta * ATTACHED_SPEED_FACTOR
			av = -rotation * delta  # Уменьшаем вращение, чтобы объект стабилизировался
		
		# Состояние перетаскивания объекта игроком
		State.STATE_DRAGGED:
			# Рассчитываем силу, которую применяет игрок при натягивании рогатки
			var player_force = get_global_mouse_position() - launch_pos
			var angle = diff_pos.angle()
			# Угловая скорость объекта синхронизируется с движением игрока
			av = (angle - rotation) * delta

			# Ограничиваем длину силы в зависимости от угла натяжения
			if angle < DRAGGED_LIMIT_ANGLE_1 and angle > DRAGGED_LIMIT_ANGLE_2:
				player_force = player_force.limit_length(DRAGGED_FORCE_LIMIT_1)
			else:
				player_force = player_force.limit_length(DRAGGED_FORCE_LIMIT_2)

			# Применяем силу к объекту
			lv = (player_force + diff_pos) * delta * ATTACHED_SPEED_FACTOR
		
		# Состояние, когда объект отпущен, но не запущен
		State.STATE_RELEASED:
			# Когда объект достаточно близко к месту запуска, он переходит в состояние полета
			if diff_pos.length() < impulse.length():
				self.state = State.STATE_LAUNCHED
			else:
				# Объект продолжает двигаться с заданным импульсом
				lv = impulse * delta
		
		# Состояние полета после запуска
		State.STATE_LAUNCHED:
			# Угловая скорость объекта изменяется в зависимости от его движения
			av = (lv.angle() - rotation) * delta
	
	# Устанавливаем обновленные значения линейной и угловой скорости
	st.set_linear_velocity(lv)
	st.set_angular_velocity(av)

# Обработка событий ввода (например, когда игрок касается экрана)
func _input_event(viewport, event, shape_idx):
	if event.is_action_pressed("touch"):
		self.state = State.STATE_DRAGGED  # При касании объект начинает перетаскиваться игроком

# Функция для прикрепления объекта к рогатке
func attach_to(slingshot):
	self.slingshot = slingshot  # Связываем объект с рогаткой
	self.state = State.STATE_TRANSFERED  # Переводим объект в состояние переноса к рогатке
