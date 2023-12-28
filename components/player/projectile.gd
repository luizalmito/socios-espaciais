extends Area3D

var origin
signal hit(font, target)

var linear_velocity: Vector3

func _process(delta):
	linear_velocity = -5 * transform.basis.z
	position += linear_velocity * delta
	await get_tree().create_timer(5).timeout
	queue_free()

func on_hit(body):
	hit.emit(origin, body)
	queue_free()
