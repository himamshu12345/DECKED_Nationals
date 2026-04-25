extends CharacterBody2D

@onready var opponent: CharacterBody2D = null
@onready var hit_particles: CPUParticles2D = $HitParticles

var knockback: Vector2 = Vector2.ZERO
var knockback_timer: float = 0.0

func _ready():
	add_to_group("players")

func _physics_process(delta: float) -> void:
	if opponent == null:
		_find_opponent()
		
	if opponent != null:
		var direction = (opponent.global_position - global_position).normalized()
		rotation = direction.angle() + PI / 2
	
	if knockback_timer > 0.0:
		velocity = knockback
		knockback_timer -= delta
		if knockback_timer <= 0.0:
			knockback = Vector2.ZERO
		move_and_slide()

func _find_opponent() -> void:
	var players = get_tree().get_nodes_in_group("players")
	for p in players:
		if p != self and p is CharacterBody2D:
			opponent = p
			break
	var enemies = get_tree().get_nodes_in_group("enemies")
	for e in enemies:
		if e != self and e is CharacterBody2D:
			opponent = e
			break
			
func apply_knockback(direction: Vector2, force: float, knockback_duration: float) -> void:
	knockback = direction * force
	knockback_timer = knockback_duration
	_emit_hit_particles(direction)


func _emit_hit_particles(knockback_direction: Vector2) -> void:
	hit_particles.global_rotation = (-knockback_direction).angle() - PI / 2
	hit_particles.direction = Vector2(0, -1)
	hit_particles.restart()
