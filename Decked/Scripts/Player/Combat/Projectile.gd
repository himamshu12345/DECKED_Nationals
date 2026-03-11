extends AnimatedSprite2D
class_name Projectile

@export var speed := 200.0
@export var lifetime := 3.0
@onready var hitbox: HitBox = $HitBox


var direction := Vector2.RIGHT
var damage := 5
var instigator: Node


func _ready():
	play()
	hitbox.damage = damage
	hitbox.enable()
	hitbox.area_entered.connect(_on_hitbox_area_entered)
	await get_tree().create_timer(lifetime).timeout
	queue_free()

func _physics_process(delta):
	position += direction * speed * delta

func initialize(dir: Vector2, dmg: int):
	direction = dir.normalized()
	damage = dmg
	hitbox.damage = damage
	
	rotation = direction.angle() + PI / 2

func _on_hitbox_area_entered(area: Area2D):
	if area is HurtBox:
		if area.owner == instigator:
			return
		queue_free()
