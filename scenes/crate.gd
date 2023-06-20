extends RigidBody2D
class_name Crate

@export var PICKUP_SCENE: PackedScene

func destroy():
	_create_pickup()
	queue_free()
	
	
func _create_pickup():
	var pickup = PICKUP_SCENE.instantiate()
	pickup.global_position = global_position
	get_parent().add_child(pickup)
