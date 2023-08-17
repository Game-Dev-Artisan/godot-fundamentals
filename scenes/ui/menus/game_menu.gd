extends Control

signal return_to_game()
signal main_menu()

@export var action_items: Array[String]

@onready var SFX_BUS_ID = AudioServer.get_bus_index("SFX")
@onready var MUSIC_BUS_ID = AudioServer.get_bus_index("Music")
@onready var buttons_v_box = %ButtonsVBox
@onready var settings_grid_container = %SettingsGridContainer
@onready var main_menu_button = %MainMenuButton
@onready var music_slider = %MusicSlider
@onready var sfx_slider = %SFXSlider
@onready var input_type_button = %InputTypeButton

var user_prefs: UserPreferences

func _ready():
	user_prefs = UserPreferences.load_or_create()
	if sfx_slider:
		sfx_slider.value = user_prefs.sfx_audio_level
	if music_slider:
		music_slider.value = user_prefs.music_audio_level
	if input_type_button:
		input_type_button.selected = user_prefs.input_type
	create_action_remap_items()
	
	
func _on_music_slider_value_changed(value):
	AudioServer.set_bus_volume_db(MUSIC_BUS_ID, linear_to_db(value))
	AudioServer.set_bus_mute(MUSIC_BUS_ID, value < .05)
	if user_prefs:
		user_prefs.music_audio_level = value
		user_prefs.save()


func _on_sfx_slider_value_changed(value):
	AudioServer.set_bus_volume_db(SFX_BUS_ID, linear_to_db(value))
	AudioServer.set_bus_mute(SFX_BUS_ID, value < .05)
	if user_prefs:
		user_prefs.sfx_audio_level = value
		user_prefs.save()


func focus_button() -> void:
	if buttons_v_box:
		var button: Button = buttons_v_box.get_child(0)
		if button is Button:
			button.grab_focus()


func _on_visibility_changed():
	if visible:
		focus_button()


func _on_return_to_game_button_pressed():
	return_to_game.emit()


func _on_main_menu_button_pressed():
	main_menu.emit()


func _on_quit_button_pressed():
	get_tree().quit()


func _on_input_type_button_item_selected(index):
	if index != -1:
		Game.INPUT_SCHEME = index
		EventBus.input_scheme_changed.emit(index)
		if user_prefs:
			user_prefs.input_type = index
			user_prefs.save()
		
		
func create_action_remap_items() -> void:
	var previous_item = settings_grid_container.get_child(-1)
	for index in range(action_items.size()):
		var action = action_items[index]
		var label = Label.new()
		label.text = action
		settings_grid_container.add_child(label)
		
		var button = RemapButton.new()
		button.action = action
		button.focus_neighbor_top = previous_item.get_path()
		previous_item.focus_neighbor_bottom = button.get_path()
		if index == action_items.size() - 1:
			main_menu_button.focus_neighbor_top = button.get_path()
			button.focus_neighbor_bottom = main_menu_button.get_path()
		previous_item = button
		
		if user_prefs:
			if user_prefs.action_events.has(action):
				var event = user_prefs.action_events[action]
				InputMap.action_erase_events(action)
				InputMap.action_add_event(action, event)
			button.action_remapped.connect(_on_action_remapped)
		settings_grid_container.add_child(button)
		
	
func _on_action_remapped(action: String, event: InputEvent) -> void:
	if user_prefs:
		user_prefs.action_events[action] = event
		user_prefs.save()
