extends Node3D

var shoot_cd = false

signal shoot(position, rotation, font, type)

func _ready():
	pass

func _process(_delta):
	if Input.is_action_pressed("shoot"):
		shooting()

func shooting():
	if !shoot_cd:
		shoot.emit($muzzle.global_position, global_rotation, get_parent().get_parent())
		shoot_cd = true
		await get_tree().create_timer(0.2).timeout
		shoot_cd = false
