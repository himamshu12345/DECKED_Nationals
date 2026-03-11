extends CharacterBody2D
class_name Boss


@export var attack_distance: float = 15.0
@export var detection_range: float = 300.0
@export var health_node: Health


@export_group("AI Personality")
@export var aggression: float = 0.7 
@export var caution: float = 0.5
@export var patience: float = 0.3  
@export var reaction_time: float = 0.15

var opponent: Node2D = null

# Combat tracking
var consecutive_hits_taken: int = 0
var time_since_hit: float = 0.0
var player_attack_count: int = 0
var time_since_damaged_player: float = 99.0

var punch_cooldown: float = 0.0
var dash_cooldown: float = 0.0
var shield_cooldown: float = 0.0
var charge_punch_cooldown: float = 0.0

var is_active: bool = false
func _on_start_game():
	is_active = true
	print("BOSS STARTED")

var action_history: Array[Dictionary] = []
var successful_actions: Dictionary = {
	"BossPunch": 0,
	"BossDash": 0,
	"BossShield": 0,
	"BossChargePunch": 0
}

func _ready() -> void:
	add_to_group("enemies")
	
	if health_node:
		health_node.health_changed.connect(_on_health_changed)
	else:
		push_error("No health node assigned!")

func _physics_process(delta: float) -> void:
	if opponent == null:
		_find_opponent()
	if opponent != null:
		var direction = (opponent.global_position - global_position).normalized()
		rotation = direction.angle() + PI / 2
	if not is_active:
		return
		
	punch_cooldown = max(0, punch_cooldown - delta)
	dash_cooldown = max(0, dash_cooldown - delta)
	shield_cooldown = max(0, shield_cooldown - delta)
	charge_punch_cooldown = max(0, charge_punch_cooldown - delta)
	time_since_hit += delta
	time_since_damaged_player += delta
	
	
	
	
	
	move_and_slide()

func _find_opponent() -> void:
	var players = get_tree().get_nodes_in_group("players")
	for p in players:
		if p != self:
			opponent = p
			return



func get_next_action() -> String:
	if opponent == null:
		return "BossIdle"
	
	var actions: Array[Dictionary] = []
	
	actions.append(_evaluate_shield())
	actions.append(_evaluate_dodge_dash())
	actions.append(_evaluate_attack_dash())
	actions.append(_evaluate_charge_punch())
	actions.append(_evaluate_punch())
	actions.append(_evaluate_counter())
	actions.append(_evaluate_follow())

	actions.sort_custom(func(a, b): return a.priority > b.priority)
	
	for i in range(min(3, actions.size())):
		var a = actions[i]
	

	for action in actions:
		if action.available:
			_record_action(action.name)
			return action.name
	
	return "BossIdle"


func _evaluate_shield() -> Dictionary:
	var distance = get_distance_to_opponent()
	var health_percent = get_health_percent()
	
	var priority = 0.0
	var available = (shield_cooldown <= 0)
	
	if not available:
		return {"name": "BossShield", "priority": 0, "available": false}
	
	if health_percent < 0.3:
		priority += 80 * caution
	
	if consecutive_hits_taken >= 2:
		priority += 90 * caution
	
	if player_attack_count > 2:
		priority += 70
		
	if _is_player_attacking():
		priority += 150 * reaction_time
	
	if distance > attack_distance and distance < 40:
		priority += 40 * (1.0 - aggression)
	
	return {
		"name": "BossShield",
		"priority": priority,
		"available": available
	}

func _evaluate_dodge_dash() -> Dictionary:
	var distance = get_distance_to_opponent()
	var health_percent = get_health_percent()
	
	var priority = 0.0
	var available = (dash_cooldown <= 0)
	
	if not available:
		return {"name": "BossDash", "priority": 0, "available": false}
	
	if health_percent < 0.4 and distance < attack_distance:
		priority += 85 * caution
	
	if time_since_hit < 0.5 and distance < attack_distance * 1.5:
		priority += 75 * caution
	
	if distance < attack_distance * 0.7:
		priority += 50 * caution
	
	if priority > 0:
		return {
			"name": "BossDash",
			"priority": priority,
			"available": available,
			"context": "dodge"
		}
	else:
		return {"name": "BossDash", "priority": 0, "available": false}

func _evaluate_attack_dash() -> Dictionary:
	var distance = get_distance_to_opponent()
	
	var priority = 0.0
	var available = (dash_cooldown <= 0)
	
	if not available:
		return {"name": "BossDash", "priority": 0, "available": false}
	
	if distance > attack_distance and distance < 80:
		priority += 60 * aggression
	
	if _is_player_retreating():
		priority += 50
	
	if action_history.size() >= 3:
		var recent = action_history.slice(-3)
		var follow_count = recent.filter(func(a): return a.name == "Follow").size()
		if follow_count >= 2:
			priority += 40  # Mix it up!
	
	var dash_success = successful_actions.get("BossDash", 0)
	if dash_success > 2:
		priority += 15
	
	return {
		"name": "BossDash",
		"priority": priority,
		"available": available,
		"context": "attack"
	}

func _evaluate_charge_punch() -> Dictionary:
	var distance = get_distance_to_opponent()
	var health_percent = get_health_percent()
	var is_isshin = (name == "Boss3")
	
	var priority = 0.0
	var available = (charge_punch_cooldown <= 0)
	
	if not available:
		return {"name": "BossChargePunch", "priority": 0, "available": false}
	
	if distance > attack_distance * 1.5 and distance < 100:
		priority += 65 * aggression
	
	if distance > 60:
		if is_isshin:
			priority += 40
		else:
			priority = 0
			available = false
	
	if health_percent < 0.4:
		priority += 50 * aggression
	
	var charge_success = successful_actions.get("BossChargePunch", 0)
	if charge_success > 2:
		priority += 25
	
	if action_history.size() >= 5:
		var recent = action_history.slice(-5)
		var charge_count = recent.filter(func(a): return a.name == "BossChargePunch").size()
		if charge_count == 0:
			priority += 20
	
	if distance < attack_distance:
		priority = 0
		available = false
	
	return {
		"name": "BossChargePunch",
		"priority": priority,
		"available": available
	}

func _evaluate_punch() -> Dictionary:
	var distance = get_distance_to_opponent()
	
	var priority = 0.0
	var available = (punch_cooldown <= 0 and distance <= attack_distance)
	
	if not available:
		return {"name": "BossPunch", "priority": 0, "available": false}
	
	priority += 70 * aggression 
	
	if time_since_damaged_player < 0.8:
		priority += 50 
	
	var punch_success = successful_actions.get("BossPunch", 0)
	if punch_success > 3:
		priority += 20
	elif punch_success < -2:
		priority -= 20
	
	return {
		"name": "BossPunch",
		"priority": priority,
		"available": available
	}

func _evaluate_counter() -> Dictionary:
	var distance = get_distance_to_opponent()
	
	var priority = 0.0
	var available = (punch_cooldown <= 0 and distance <= attack_distance)
	
	if not available:
		return {"name": "BossPunch", "priority": 0, "available": false}
	
	if time_since_hit < 0.3:
		priority += 100 * aggression
	
	if priority > 0:
		return {
			"name": "BossPunch",
			"priority": priority,
			"available": available,
			"context": "counter"
		}
	else:
		return {"name": "BossPunch", "priority": 0, "available": false}

func _evaluate_follow() -> Dictionary:
	var distance = get_distance_to_opponent()
	
	var priority = 0.0
	var available = true 
	
	if distance > attack_distance:
		priority = 35
		
		if distance > 100:
			priority += 25
	
		priority += 20 * patience
	else:
		priority = 5
	
	return {
		"name": "Follow",
		"priority": priority,
		"available": available
	}


func _record_action(action_name: String) -> void:
	var record = {
		"name": action_name,
		"time": Time.get_ticks_msec() / 1000.0,
		"distance": get_distance_to_opponent(),
		"health": get_health_percent()
	}
	
	action_history.append(record)
	
	if action_history.size() > 20:
		action_history.pop_front()

func record_successful_action(action_name: String) -> void:
	successful_actions[action_name] = successful_actions.get(action_name, 0) + 1


func record_failed_action(action_name: String) -> void:
	successful_actions[action_name] = successful_actions.get(action_name, 0) - 1

func on_successful_hit() -> void:
	time_since_damaged_player = 0.0
	consecutive_hits_taken = max(0, consecutive_hits_taken - 1)
	player_attack_count = max(0, player_attack_count - 1)


func _is_player_retreating() -> bool:
	if opponent == null:
		return false
	
	var distance = get_distance_to_opponent()
	var prev_distance = get_meta("previous_distance", distance)
	set_meta("previous_distance", distance)
	
	return distance > prev_distance + 2.0 

func _is_player_attacking() -> bool:
	if opponent == null or not opponent.has_node("StateMachine"):
		return false
	var opp_state = opponent.get_node("StateMachine").current_state.name
	return opp_state in ["Punch", "ChargePunch"]



func _on_health_changed(new_health: int) -> void:
	var previous_health = get_meta("previous_health", new_health)
	
	if new_health < previous_health:
		var damage = previous_health - new_health
		on_damage_taken(damage)
	
	set_meta("previous_health", new_health)

func on_damage_taken(amount: int) -> void:
	consecutive_hits_taken += 1
	time_since_hit = 0.0
	
	if get_health_percent() < 0.4:
		caution = min(1.0, caution + 0.05)
	
	await get_tree().create_timer(1.5).timeout
	if consecutive_hits_taken > 0:
		consecutive_hits_taken -= 1


func set_punch_cooldown(duration: float) -> void:
	punch_cooldown = duration

func set_dash_cooldown(duration: float) -> void:
	dash_cooldown = duration

func set_shield_cooldown(duration: float) -> void:
	shield_cooldown = duration

func set_charge_punch_cooldown(duration: float) -> void:
	charge_punch_cooldown = duration


func get_distance_to_opponent() -> float:
	if opponent == null:
		return 9999.9
	return global_position.distance_to(opponent.global_position)

func get_direction_to_opponent() -> Vector2:
	if opponent == null:
		return Vector2.ZERO
	return global_position.direction_to(opponent.global_position)

func get_health_percent() -> float:
	if health_node == null or health_node.max_health == 0:
		return 1.0
	return float(health_node.current_health) / float(health_node.max_health)
