extends CanvasLayer
class_name UI

@onready var score_label = %Score
@onready var reload_progress = %ReloadProgress
@onready var SFX_BUS_ID = AudioServer.get_bus_index("SFX")
@onready var MUSIC_BUS_ID = AudioServer.get_bus_index("Music")
@onready var menu = %Menu

var score = 0:
	set(new_score):
		score = new_score
		_update_score_label()
		
		
func _ready():
	_update_score_label()
		
		
func _input(event):
	if event.is_action_pressed("ui_cancel"):
		menu.visible = !menu.visible
		
		
func _update_score_label():
	score_label.text = str(score)
	
	
func _on_collected(collectable) -> void:
	if collectable:
		score += 100


func _on_reload_progress(progress) -> void:
	reload_progress.value = progress
	
	
func _on_reloaded() -> void:
	reload_progress.value = 1


func _on_music_slider_value_changed(value):
	AudioServer.set_bus_volume_db(MUSIC_BUS_ID, linear_to_db(value))
	AudioServer.set_bus_mute(MUSIC_BUS_ID, value < .05)


func _on_sfx_slider_value_changed(value):
	AudioServer.set_bus_volume_db(SFX_BUS_ID, linear_to_db(value))
	AudioServer.set_bus_mute(SFX_BUS_ID, value < .05)
