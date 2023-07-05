extends Area2D
class_name Pickup

@onready var audio_player = $AudioStreamPlayer

func _on_body_entered(body):
	if body is Tank:
		body.collect(self)
		audio_player.play()
		await audio_player.finished
		queue_free()
