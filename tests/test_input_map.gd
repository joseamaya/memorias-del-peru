extends RefCounted
## Comprueba que las acciones del Input Map existen y tienen eventos.


func test_input_map() -> bool:
	var actions: Array[StringName] = [
		&"move_forward",
		&"move_backward",
		&"move_left",
		&"move_right",
		&"run",
		&"interact",
		&"jump",
		&"pause",
	]
	for action: StringName in actions:
		if not InputMap.has_action(action):
			return false
		if InputMap.action_get_events(action).is_empty():
			return false
	return true
