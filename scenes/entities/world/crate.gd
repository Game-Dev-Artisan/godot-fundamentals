extends RigidBody2D
class_name Crate

@export var PICKUP_SCENE: PackedScene
@onready var audio_player = $AudioStreamPlayer

func destroy():
	audio_player.play()
	await audio_player.finished
	queue_free()
	var pickup: Pickup = PICKUP_SCENE.instantiate()
	pickup.global_position = global_position
	get_parent().add_child(pickup)
