extends Node

var login_id = "bsota"

func _ready():
	IEOS.connect_interface_login_callback.connect(func (data: Dictionary):
		if data.local_user_id != "":
			login_id = data.local_user_id
	)

func _process(_delta: float):
	IEOS.tick()
