extends Node3D

func _ready():
	$Ship.shoot.connect(shooting)

func shooting(p_position, p_rotation, font, _type = "default"):
	var projectile = preload("res://components/player/projectile.tscn").instantiate()
	add_child(projectile)
	projectile.origin = font
	projectile.hit.connect(deal_damage)
	projectile.global_position = p_position
	projectile.global_rotation = p_rotation

func deal_damage(font, target):
	if font == target:
		return
	target.queue_free()
