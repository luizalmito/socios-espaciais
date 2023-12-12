extends Node3D

func _ready():
	$Ship.shoot.connect(shooting)

func shooting(p_position, p_rotation):
	var projectile = preload("res://scenes/projectile.tscn").instantiate()
	add_child(projectile)
	projectile.global_position = p_position
	projectile.global_rotation = p_rotation
