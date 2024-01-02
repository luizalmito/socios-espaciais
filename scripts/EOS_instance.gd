extends Node

func _ready() -> void:
	# Initialize the SDK
	var init_options = EOS.Platform.InitializeOptions.new()
	init_options.product_name = "Zorba Games"
	init_options.product_version = "1.0"

	var init_result := EOS.Platform.PlatformInterface.initialize(init_options)
	if init_result != EOS.Result.Success:
		print("Failed to initialize EOS SDK: ", EOS.result_str(init_result))
		return

	# Create platform
	var create_options = EOS.Platform.CreateOptions.new()
	create_options.product_id = "5ff0976c91c147b3bb5df7989b822414"
	create_options.sandbox_id = "27d6ff8048844241b5216604c7acbdd2"
	create_options.deployment_id = "b8471922957e4ceda94ff2ea753d26bf"
	create_options.client_id = "xyza7891i2gRsg7rmszn6Nd7OGkzfUOl"
	create_options.client_secret = "qCnARS2EJ0sNt9E7ptOm926JYWXVwRHfjMAHP4tQHAM"
	create_options.encryption_key = ""

	# Enable Social Overlay on Windows
	if OS.get_name() == "Windows":
		create_options.flags = EOS.Platform.PlatformFlags.WindowsEnableOverlayOpengl

	var create_success := EOS.Platform.PlatformInterface.create(create_options)
	if not create_success:
		print("Failed to create EOS Platform")
		return

	# Setup Logs from EOS
	EOS.get_instance().logging_interface_callback.connect(_on_logging_interface_callback)
	var res := EOS.Logging.set_log_level(EOS.Logging.LogCategory.AllCategories, EOS.Logging.LogLevel.Info)
	if res != EOS.Result.Success:
		print("Failed to set log level: ", EOS.result_str(res))

	EOS.get_instance().connect_interface_login_callback.connect(_on_connect_interface_login_callback)
	EOS.get_instance().auth_interface_login_callback.connect(_on_auth_login_callback)

	$connecting_warning.hide()
	$UI.show()

func _on_logging_interface_callback(msg) -> void:
	msg = EOS.Logging.LogMessage.from(msg) as EOS.Logging.LogMessage
	print("SDK %s | %s" % [msg.category, msg.message])


func _anonymous_login() -> void:
	# Login using Device ID (no user interaction/credentials required)
	var opts = EOS.Connect.CreateDeviceIdOptions.new()
	opts.device_model = OS.get_name() + "" + OS.get_model_name()
	EOS.Connect.ConnectInterface.create_device_id(opts)
	await EOS.get_instance().connect_interface_create_device_id_callback

	var credentials = EOS.Connect.Credentials.new()
	credentials.token = null
	credentials.type = EOS.ExternalCredentialType.DeviceidAccessToken

	var login_options = EOS.Connect.LoginOptions.new()
	login_options.credentials = credentials
	var user_login_info = EOS.Connect.UserLoginInfo.new()
	user_login_info.display_name = "Anon User"
	login_options.user_login_info = user_login_info
	EOS.Connect.ConnectInterface.login(login_options)

func _on_connect_interface_login_callback(data: Dictionary) -> void:
	if not data.success:
		print("Login failed")
		EOS.print_result(data)
		return

	print_rich("[b]Login successfull[/b]: local_user_id=", data.local_user_id)
	get_tree().change_scene_to_file("res://components/menus/multiplayer_menu.tscn")

func _on_auth_login_callback(data: Dictionary) -> void:
	if not data.success:
		print("Login failed")
		EOS.print_result(data)
		return
	
	if data.local_user_id != "":
		var epic_account_id = data.local_user_id
		print("Epic Account Id: ", epic_account_id)

		var copy_user_auth_token = EOS.Auth.AuthInterface.copy_user_auth_token(EOS.Auth.CopyUserAuthTokenOptions.new(), epic_account_id)
		var token = copy_user_auth_token.token

		# Get user info of logged in user
		var options = EOS.UserInfo.QueryUserInfoOptions.new()
		options.local_user_id = epic_account_id
		options.target_user_id = epic_account_id
		EOS.UserInfo.UserInfoInterface.query_user_info(options)
		# Connect the account to get a Product User Id from the Epic Account Id
		var credentials = EOS.Connect.Credentials.new()
		credentials.token = token.access_token
		credentials.type = EOS.ExternalCredentialType.Epic
	
		var login_options = EOS.Connect.LoginOptions.new()
		login_options.credentials = credentials
		EOS.Connect.ConnectInterface.login(login_options)

func _on_annon_login_button_down():
	_anonymous_login()


func _on_dev_login_button_down():
	if $UI/DevName.text.is_empty():
		return
	var credentials = EOS.Auth.Credentials.new()
	credentials.token = $UI/DevName.text
	credentials.type = EOS.Auth.LoginCredentialType.Developer
	credentials.id = "localhost:7878"
	
	var login_options = EOS.Auth.LoginOptions.new()
	login_options.credentials = credentials
	login_options.scope_flags = EOS.Auth.ScopeFlags.BasicProfile
	EOS.Auth.AuthInterface.login(login_options)
