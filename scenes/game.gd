extends Node2D
class_name Game

@export var tank: Tank
@export var ui: UI

@onready var camera: Camera = $Camera2D

func _ready():
	if !tank.collected.is_connected(ui._on_collected):
		tank.collected.connect(ui._on_collected)
	if !tank.reload_progress.is_connected(ui._on_reload_progress):
		tank.reload_progress.connect(ui._on_reload_progress)
	if !tank.reloaded.is_connected(ui._on_reloaded):
		tank.reloaded.connect(ui._on_reloaded)
		
	call_deferred("start_game")
	

func start_game():
	await get_tree().create_timer(2).timeout
	var crate: Crate = World.get_closest_crate_to(tank.position)
	if !crate:
		return
	tank.has_control = false
	camera.change_mode(Camera.MODES.TARGET)
	camera.change_target(crate)
	UI.open_letterbox()
	
	await get_tree().create_timer(3).timeout
	UI.close_letterbox()
	camera.change_target(tank)
	camera.change_mode(Camera.MODES.TARGET_MOUSE_BLENDED)
	tank.has_control = true
