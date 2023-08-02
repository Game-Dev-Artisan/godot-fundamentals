extends Node2D
class_name Game

@export var TankScene: PackedScene
@export var WorldScene: PackedScene
@export var ui: UI

@onready var camera: Camera = $Camera2D

var tank: Tank
var world: World

enum INPUT_SCHEMES { KEYBOARD_AND_MOUSE, GAMEPAD, TOUCH_SCREEN }
static var INPUT_SCHEME: INPUT_SCHEMES = INPUT_SCHEMES.KEYBOARD_AND_MOUSE

func start_game():
	world = WorldScene.instantiate()
	add_child(world)
	move_child(world, 0)
	
	tank = TankScene.instantiate()
	world.add_child(tank)
	tank.position = Vector2(922, 623)
	tank.collected.connect(ui._on_collected)
	tank.reload_progress.connect(ui._on_reload_progress)
	tank.reloaded.connect(ui._on_reloaded)
	
	camera.change_target(tank)
	get_tree().paused = false
	
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


func _on_ui_start_game():
	start_game()


func _on_ui_quit_to_menu():
	if world:
		world.queue_free()
		world = null
	tank = null
	camera.reset()


func _on_ui_menu_closed():
	get_tree().paused = false


func _on_ui_menu_opened():
	get_tree().paused = true 
