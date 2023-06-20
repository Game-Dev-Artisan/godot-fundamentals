extends Area2D

@onready var animation_player = $AnimationPlayer


func _ready():
	animation_player.play("idle")


func _on_body_entered(body):
	if body is Tank:
		body.collect(self)
		queue_free()
