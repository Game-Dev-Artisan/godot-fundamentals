extends Camera2D
class_name Camera

enum MODES { TARGET, TARGET_MOUSE_BLENDED }

@export var target: Node = null:
	set(tar):
		fallback_target = tar if fallback_target == null else fallback_target
		target = tar
@export var mode: MODES = MODES.TARGET_MOUSE_BLENDED
@export var MAX_DISTANCE: float = 50
@export var SMOOTH_SPEED: float = 1

var target_position := Vector2.INF
var fallback_target: Node = null
	
	
func _process(delta):
	if !target:
		return
		
	match(mode):
		MODES.TARGET:
			target_position = target.position
		MODES.TARGET_MOUSE_BLENDED:
			if Game.INPUT_SCHEME == Game.INPUT_SCHEMES.KEYBOARD_AND_MOUSE:
				var mouse_pos := get_local_mouse_position()
				target_position = (target.position + mouse_pos)
				target_position.x = clamp(target_position.x, -MAX_DISTANCE + target.position.x, MAX_DISTANCE + target.position.x)
				target_position.y = clamp(target_position.y, -MAX_DISTANCE + target.position.y, MAX_DISTANCE + target.position.y)
			elif Game.INPUT_SCHEME == Game.INPUT_SCHEMES.GAMEPAD:
				if target.crosshair:
					target_position = target.crosshair.global_position
				else:
					target_position = target.position
				
	if target_position != Vector2.INF:
		position = lerp(position, target_position, SMOOTH_SPEED * delta)
		
		
func change_mode(new_mode: MODES) -> void:
	mode = new_mode
	
	
func change_target(new_target: Node) -> void:
	if new_target:
		if target and target.tree_exiting.is_connected(_clear_target):
			target.tree_exiting.disconnect(_clear_target)
		target = new_target
		new_target.tree_exiting.connect(_clear_target)
		
		
func _clear_target() -> void:
	target = fallback_target
	change_mode(MODES.TARGET_MOUSE_BLENDED)

func reset() -> void:
	target = null
	fallback_target = null
