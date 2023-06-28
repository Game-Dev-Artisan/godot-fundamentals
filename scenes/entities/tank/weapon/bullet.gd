extends Area2D
class_name Bullet

const SPEED = 500

var direction: Vector2 = Vector2()
var tank: Tank

func _physics_process(delta):
	position += direction.normalized() * SPEED * delta

func _on_area_entered(area):
	queue_free()


func _on_body_entered(body):
	if body is Crate:
		body.destroy()
	queue_free()
