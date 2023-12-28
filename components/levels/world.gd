extends Node3D

func _ready():
	$Ship.shoot.connect(shooting)

func shooting(p_position, p_rotation, font, type = "default"):
	var projectile = preload("res://scenes/projectile.tscn").instantiate()
	add_child(projectile)
	projectile.hit.connect(deal_damage)
	projectile.global_position = p_position
	projectile.global_rotation = p_rotation
	print("a")

func deal_damage(font, target, type):
	print("b")
	if font == target:
		return
	target.queue_free()
