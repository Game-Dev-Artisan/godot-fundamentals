extends Node2D
class_name Weapon

enum STATES { READY, FIRING, RELOADING }

@export var BULLET_SCENE: PackedScene
@export var tank: Tank

@onready var reload_timer = $ReloadTimer

var state: STATES = STATES.READY

func change_state(new_state: STATES):
	state = new_state
	
func fire():
	if state == STATES.FIRING || state == STATES.RELOADING:
		return
		
	change_state(STATES.FIRING)
	# Create a bullet at our position and set it's direction
	var bullet: Bullet = BULLET_SCENE.instantiate()
	bullet.direction = Vector2.from_angle(global_rotation)
	bullet.global_position = global_position
	bullet.tank = tank
	# Add the bullet to the root scene so translation is in world space
	get_tree().root.add_child(bullet)
	# Set our state to reload and start our timer
	change_state(STATES.RELOADING)
	reload_timer.start()
	
	


func _on_reload_timer_timeout():
	change_state(STATES.READY)
