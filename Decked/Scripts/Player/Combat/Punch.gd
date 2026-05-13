extends State
class_name Punch

@export var player: AnimatedSprite2D
@export var input_prefix := ""
@export var hitbox: HitBox
@export var audio: AudioStreamPlayer2D
@export var punchSpeed: float = 1
@export var bulldozer_buff: float = 1

const CHARGE_THRESHOLD := 0.3
const BASE_DAMAGE := 7

var damage := BASE_DAMAGE
var punchRightNext := false
var chargeTime := 0.0
var isCharging := false
var punchReleased := false

func Enter(): 
	chargeTime = 0.0
	isCharging = false
	punchReleased = false

	damage = BASE_DAMAGE
	if input_prefix == "":
		damage += GameManager.p1_stats["damage_bonus"]
		punchSpeed = GameManager.p1_stats.get("punchSpeed", 0)
		bulldozer_buff = GameManager.p1_stats.get("bulldozer", 0)
	else:
		damage += GameManager.p2_stats["damage_bonus"]
		punchSpeed = GameManager.p2_stats.get("punchSpeed", 0)
		bulldozer_buff = GameManager.p2_stats.get("bulldozer", 0)

	if not player.animation_finished.is_connected(_on_animation_finished):
		player.animation_finished.connect(_on_animation_finished)
		
	damage += bulldozer_buff*get_parent().get_parent().get_node_or_null("Health").max_health

func Exit():
	if player.animation_finished.is_connected(_on_animation_finished):
		player.animation_finished.disconnect(_on_animation_finished)


func Update(delta: float):
	if Input.is_action_pressed(input_prefix + "Punch") and not punchReleased:
		chargeTime += delta

		if chargeTime >= CHARGE_THRESHOLD and not isCharging:
			isCharging = true
			transition_state.emit(self, "ChargePunch")

	if Input.is_action_just_released(input_prefix + "Punch") and not punchReleased:
		punchReleased = true
		perform_punch()

	if Input.is_action_just_pressed(input_prefix + "Shield"):
		transition_state.emit(self, "Shield")


func perform_punch():
	hitbox.damage = damage
	var health = get_parent().get_parent().get_node_or_null("Health")
	var anim := "Right Punch" if punchRightNext else "Left Punch"
	punchRightNext = !punchRightNext
	
	var speed = punchSpeed
	if health.current_health/ health.max_health <= 0.33:
		speed *= 1+health.unstoppable*2
	
	player.speed_scale = punchSpeed*speed
	player.play(anim)
	audio.play()
	hitbox.enable()

	var stamina = _get_stamina()
	if stamina:
		stamina.consume(Stamina.COST_PUNCH)
		
func _on_animation_finished():
	if player.animation == "Left Punch" or player.animation == "Right Punch":
		hitbox.disable()
		transition_state.emit(self, "Idle")


func on_charge_hit():
	transition_state.emit(self, "ConfusedStaggered")

func Physics_Update(_delta: float):
	var left = input_prefix + "left"
	var right = input_prefix + "right"
	var up = input_prefix + "up" 
	var down = input_prefix + "down"
	var direction = Input.get_vector(left, right, up, down)
	
	var base_speed = 50
	var current_speed = base_speed
	if input_prefix == "":
		current_speed = base_speed * (1.0 + GameManager.p1_stats.get("speed_bonus", 0) / 100.0)
	else:
		current_speed = base_speed * (1.0 + GameManager.p2_stats.get("speed_bonus", 0) / 100.0)
		
	if owner is CharacterBody2D:
		owner.velocity = direction * current_speed
		owner.move_and_slide()


func _get_stamina() -> Stamina:
	if owner:
		return owner.get_node_or_null("Stamina")
	return null
