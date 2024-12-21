extends CanvasLayer

signal restart_level
# Called when the node enters the scene tree for the first time.
func _ready():
	$PanelContainer.hide()
	$RestartButton.hide()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func display():
	await get_tree().create_timer(2).timeout
	$PanelContainer.show()
	await get_tree().create_timer(2).timeout
	$RestartButton.show()
	$PanelContainer/Message.text = "Restart ?"


func _on_restart_button_pressed():
	emit_signal("restart_level")
