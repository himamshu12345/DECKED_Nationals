class_name HurtBox
extends Area2D

var camera: Camera2D

const HIT_EFFECT_LIGHT = preload("res://Decked/Scenes/Misc/punch_effect.tscn")
const HIT_EFFECT_HEAVY = preload("res://Decked/Scenes/Misc/punch_effect_heavy.tscn")
@export var hitAudio: AudioStreamPlayer2D
func _ready() -> void:
	area_entered.connect(_on_area_entered)
	camera = get_viewport().get_camera_2d()

func _on_area_entered(area: Area2D) -> void:
	if area is HitBox:
		var hitbox := area as HitBox
		var health = owner.get_node_or_null("Health")
		
		var impact_position = (global_position + hitbox.global_position) / 2
		var enemy = hitbox.owner
		var enemy_state: String = ""
		
		if enemy and enemy.has_node("StateMachine"):
			enemy_state = enemy.get_node("StateMachine").current_state.name
		
		if "instigator" in enemy and enemy.instigator == owner:
			return

		if health:
			_play_animation(impact_position, hitbox.damage)
			health.take_damage(hitbox.damage, enemy_state, enemy)
			hitAudio.play()
				
func _play_animation(impact_position: Vector2, damage: int) -> void:
	
	var effect_scene = HIT_EFFECT_HEAVY if damage > 5 else HIT_EFFECT_LIGHT
	
	var effect = effect_scene.instantiate()
	get_tree().current_scene.add_child(effect)
	
	var random_offset = Vector2(randf_range(-5,5),randf_range(-5,5))
	
	effect.global_position = impact_position + random_offset
	
	var sprite: AnimatedSprite2D = null
	
	if effect is AnimatedSprite2D:
		sprite = effect
	else:
		sprite = effect.get_node_or_null("AnimatedSprite2D")
	
	if sprite:
		var anim_name = sprite.animation if sprite.animation else "default"
		
		if sprite.sprite_frames and sprite.sprite_frames.get_animation_names().size() > 0:
			anim_name = sprite.sprite_frames.get_animation_names()[0]
	
		
		sprite.frame = 0
		sprite.play(anim_name)
		
		sprite.animation_finished.connect(func(): effect.queue_free())
	else:
		effect.queue_free()
	
	if camera:
		var shake_intensity = 1.0 if damage > 5 else 0.2
		var shake_duration = 0.3 if damage > 5 else 0.15
		_camera_shake(shake_intensity, shake_duration)

func _camera_shake(intensity: float, duration: float) -> void:
	if not camera:
		return
	var original_offset = camera.offset
	var shake_timer = 0.0
	
	while shake_timer < duration:
		camera.offset = Vector2(
			randf_range(-intensity, intensity),
			randf_range(-intensity, intensity)
		)
		
		
		shake_timer += get_process_delta_time()
		if not is_inside_tree():
			return
		await get_tree().process_frame
	
	camera.offset = original_offset
