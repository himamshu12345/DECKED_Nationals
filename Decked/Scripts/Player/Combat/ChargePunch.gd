extends State
class_name ChargePunch

@export var player: CharacterBody2D
@export var animator: AnimatedSprite2D
@export var input_prefix := ""
@export var hitbox: HitBox
@export var speed = 25
@export var charge_audio: AudioStreamPlayer2D
@export var projectile_audio: AudioStreamPlayer2D
@export var charge_released_audio: AudioStreamPlayer2D

const PROJECTILE_SCENE = preload("res://Decked/Scenes/Player/projectile.tscn")

const BASE_DAMAGE := 2
const FRAMES_PER_CHARGE := 42
const DAMAGE_PER_LEVEL := 3
const MAX_CHARGE_LEVELS := 5
const MAX_CHARGE_HITS := 2

var damage := BASE_DAMAGE
var punchRightNext := false
var chargeFrames := 0
var isCharging := false
var punchReleased := false
var chargeLevel = 0
var chargeHits = 0

var canShoot := false


func Enter():
	
	punchReleased = false
	chargeFrames = 0
	chargeLevel = 0
	chargeHits = 0
	animator.play("ChargePunch")
	charge_audio.play()
	
	if input_prefix == "":
		damage += GameManager.p1_stats["damage_bonus"]
	else:
		damage += GameManager.p2_stats["damage_bonus"]

	if not animator.animation_finished.is_connected(_on_animation_finished):
		animator.animation_finished.connect(_on_animation_finished)


func Exit():
	if animator.animation_finished.is_connected(_on_animation_finished):
		animator.animation_finished.disconnect(_on_animation_finished)
	charge_audio.stop()
	charge_released_audio.play()


func Update(_delta: float):
	var punch = input_prefix + "Punch"
	var shield = input_prefix + "Shield"

	chargeFrames += 1
	chargeLevel = int(chargeFrames / FRAMES_PER_CHARGE)
	chargeLevel = clamp(chargeLevel, 0, MAX_CHARGE_LEVELS)

	if Input.is_action_just_released(punch) and not punchReleased:
		punchReleased = true
		perform_punch()

func on_charge_hit():
	chargeHits+=1
	if chargeHits >= MAX_CHARGE_HITS:
		break_charge()
		
func on_charge_interrupted():
	break_charge()

func break_charge():
	transition_state.emit(self, "QuickStagger")

func perform_punch():
	hitbox.damage = damage + (chargeLevel * DAMAGE_PER_LEVEL)
	var anim := "Right Punch" if punchRightNext else "Left Punch"
	punchRightNext = !punchRightNext
	animator.play(anim)
	hitbox.enable()

func _on_animation_finished():
	if animator.animation == "Left Punch" or animator.animation == "Right Punch":
		hitbox.disable()
		if chargeLevel > 0:
			if canShoot:
				shoot_projectile()
		transition_state.emit(self, "Idle")

func Physics_Update(delta: float):
	var left = input_prefix + "left"
	var right = input_prefix + "right"
	var up = input_prefix + "up"
	var down = input_prefix + "down"
	
	var direction = Input.get_vector(left, right, up, down)
	if direction != Vector2.ZERO:
		player.velocity = direction * speed
	else:
		player.velocity = Vector2.ZERO

	player.move_and_slide()

func shoot_projectile():
	projectile_audio.play()
	var projectile = PROJECTILE_SCENE.instantiate()
	get_tree().current_scene.add_child(projectile)
	projectile.global_position = hitbox.global_position 
	
	var forward_direction = Vector2(0, -1).rotated(owner.rotation)
	projectile.instigator = owner
	projectile.initialize(forward_direction, damage)
	
