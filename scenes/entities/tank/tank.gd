extends CharacterBody2D
class_name Tank

signal collected(collectable)
signal reloaded()
signal reload_progress(progress)

const SPEED = 64.0
const TURN_SPEED = 2
const ROTATE_SPEED = 20

@export var weapon: Weapon
@export var drive_water_audio: AudioStream
@export var default_drive_audio: AudioStream
@export var crosshair_range := 50.0

@onready var body_sprite := $BodySprite
@onready var animation_player = $AnimationPlayer
@onready var collider = $CollisionShape2D
@onready var left_track_particles: GPUParticles2D = $LeftTrackParticles
@onready var right_track_particles: GPUParticles2D = $RightTrackParticles
@onready var audio_player: AudioStreamPlayer = $AudioStreamPlayer
@onready var crosshair = $Crosshair


var direction := Vector2.RIGHT
var speed_modifier := 1.0
var particle_gradient: GradientTexture1D = null
var in_water := false:
	set(value):
		if in_water != value:
			if value:
				audio_player.stream = drive_water_audio
			else:
				audio_player.stream = default_drive_audio
		in_water = value
var has_control := true

func _ready():
	weapon.reloaded.connect(func (): reloaded.emit())
	weapon.reload_progress.connect(func (progress): reload_progress.emit(progress))
	EventBus.input_scheme_changed.connect(_on_input_scheme_changed)
	

func collect(pickup):
	collected.emit(pickup)
	

func _physics_process(delta):
	if !has_control:
		return
	
	var drive_input := Input.get_axis("move_backward", "move_forward")
	var turn_input := Input.get_axis("turn_left", "turn_right")
	if turn_input != 0:
		# Rotate direction based on our input vector and apply turn speed
		direction = direction.rotated(turn_input * (PI / 2) * TURN_SPEED * delta)
		rotation = direction.angle()
	if drive_input != 0:
		# Move in a forward/backward motion and play animation
		animation_player.play("move")
		in_water = World.get_custom_data_at(position, "is_water")
		particle_gradient = World.get_gradient_at(position)
		speed_modifier = World.get_custom_data_at(position, "speed_modifier")
		var move_speed = SPEED * speed_modifier
		velocity = lerp(velocity, (direction.normalized() * drive_input) * move_speed, SPEED * delta)
		if !audio_player.playing:
			audio_player.play()
	else:
		if audio_player.playing:
			audio_player.stop()
		# Bring to a stop
		velocity = Vector2.ZERO
		animation_player.play('idle')
		
	if particle_gradient and velocity:
		left_track_particles.process_material.color_ramp = particle_gradient
		right_track_particles.process_material.color_ramp = particle_gradient
		left_track_particles.emitting = true
		right_track_particles.emitting = true
	else:
		left_track_particles.emitting = false
		right_track_particles.emitting = false
		
	# Apply our movement velocity
	move_and_slide()
	
	# Apply Weapon Rotation
	update_weapon_rotation(delta)


func update_weapon_rotation(delta, force_update_position = false) -> void:
	if Game.INPUT_SCHEME == Game.INPUT_SCHEMES.KEYBOARD_AND_MOUSE:
		var mouse_pos = get_local_mouse_position()
		var new_transform = weapon.transform.looking_at(mouse_pos)
		weapon.transform = weapon.transform.interpolate_with(new_transform, ROTATE_SPEED * delta)
	elif Game.INPUT_SCHEME == Game.INPUT_SCHEMES.GAMEPAD:
		var aim_direction := Input.get_vector("weapon_aim_left", "weapon_aim_right", "weapon_aim_up", "weapon_aim_down")
		if force_update_position || aim_direction != Vector2.ZERO:
			var angle = aim_direction.angle()
			weapon.global_rotation = angle
			crosshair.global_position = global_position + (Vector2(cos(angle), sin(angle)) * crosshair_range)
		crosshair.global_rotation = 0
		
		
func _input(event):
	if !has_control:
		return
	if event.is_action_pressed("weapon_fire"):
		weapon.fire()

func _on_input_scheme_changed(scheme) -> void:
	if scheme == Game.INPUT_SCHEMES.GAMEPAD:
		crosshair.show()
		update_weapon_rotation(0, true)
	else:
		crosshair.hide()
