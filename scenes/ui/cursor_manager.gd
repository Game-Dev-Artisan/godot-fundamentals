extends Node

@export var base_window_size: Vector2 = Vector2.ZERO
@export var cursor_texture: Texture2D = null

func _ready():
	update_cursor()
	get_tree().get_root().size_changed.connect(update_cursor)
	EventBus.input_scheme_changed.connect(_on_input_scheme_changed)
	
	
func _on_input_scheme_changed(_scheme) -> void:
	update_cursor()
	
	
func update_cursor():
	if Game.INPUT_SCHEME == Game.INPUT_SCHEMES.GAMEPAD:
		Input.set_custom_mouse_cursor(null, Input.CURSOR_ARROW)
	else:
		var current_window_size := get_tree().get_root().size
		var scale_multiple = min(floor(current_window_size.x / base_window_size.x), floor(current_window_size.y / base_window_size.y))
		var image = cursor_texture.get_image()
		var scaler = cursor_texture.get_size() * (scale_multiple + 1)
		image.resize(scaler.x, scaler.y, Image.INTERPOLATE_NEAREST)
		var texture = ImageTexture.create_from_image(image)
		Input.set_custom_mouse_cursor(texture, Input.CURSOR_ARROW, scaler * .5)
