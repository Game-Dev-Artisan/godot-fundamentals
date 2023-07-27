extends CanvasLayer
class_name UI

signal start_game()
signal menu_opened()
signal menu_closed()
signal quit_to_menu()

@onready var score_label = %Score
@onready var reload_progress = %ReloadProgress
@onready var menu = %Menu
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var main_menu = %MainMenu
@onready var transition = %Transition

static var _instance: UI = null

var score = 0:
	set(new_score):
		score = new_score
		_update_score_label()
		
var letterbox_open := false
	
func _ready():
	_update_score_label()
	_instance = self if _instance == null else _instance
		
		
func _input(event):
	if !main_menu.visible and event.is_action_pressed("ui_cancel"):
		menu.visible = !menu.visible
		if menu.visible:
			menu_opened.emit()
		else:
			menu_closed.emit()
		
		
func _update_score_label():
	score_label.text = str(score)
	
	
func _on_collected(collectable) -> void:
	if collectable:
		score += 100


func _on_reload_progress(progress) -> void:
	reload_progress.value = progress
	
	
func _on_reloaded() -> void:
	reload_progress.value = 1



	
	
static func open_letterbox() -> void:
	if !_instance.letterbox_open:
		_instance.animation_player.play("open_letterbox")
		_instance.letterbox_open = true
		
		
static func close_letterbox() -> void:
	if _instance.letterbox_open:
		_instance.animation_player.play_backwards("open_letterbox")
		_instance.letterbox_open = false


func _on_main_menu_start_game() -> void:
	start_game.emit()
	transition.show()
	animation_player.play("screen_transition")
	await animation_player.animation_finished
	transition.hide()


func _on_menu_main_menu():
	if animation_player.is_playing():
		await animation_player.animation_finished
	menu.hide()
	transition.show()
	animation_player.play_backwards("screen_transition")
	await animation_player.animation_finished
	transition.hide()
	quit_to_menu.emit()
	main_menu.show()


func _on_menu_return_to_game():
	if animation_player.is_playing():
		await animation_player.animation_finished
	menu.hide()
	menu_closed.emit()
