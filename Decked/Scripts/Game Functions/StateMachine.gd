extends Node
class_name StateMachine

@export var initial_state : State

var current_state: State
var states: Dictionary = {}

func _ready():
	for child in get_children():
		if child is State:
			states[child.name.to_lower()] = child
			child.transition_state.connect(change_state)
			
	if initial_state:
		initial_state.Enter()
		current_state = initial_state
			
func _process(delta):
	if current_state:
		current_state.Update(delta)
	
func _physics_process(delta):
	if current_state:
		current_state.Physics_Update(delta)
		

func change_state(state, new_state_name):
	if state != current_state:
		return
	var new_state = states.get(new_state_name.to_lower())
	if !new_state:
		print("Failed: Could not find a child node named '" + new_state_name + "'")
		return
	if current_state:
		current_state.Exit()
	
	new_state.Enter()
	current_state = new_state

func force_change_state(new_state_name: String):
	if current_state:
		change_state(current_state, new_state_name)
