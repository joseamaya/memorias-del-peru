extends RefCounted
## Comprueba la lógica de pausa de GameManager.


var _received: Array[bool] = []


func _on_pause_changed(paused: bool) -> void:
	_received.append(paused)


func test_pause() -> bool:
	var tree: SceneTree = Engine.get_main_loop() as SceneTree
	if tree == null:
		return false
	var manager: GameManagerService = GameManagerService.new()
	if manager == null:
		return false
	tree.root.add_child(manager)
	manager.pause_changed.connect(_on_pause_changed)
	var ok: bool = true
	manager.set_paused(true)
	ok = ok and tree.paused
	ok = ok and manager.is_paused()
	ok = ok and _received.size() == 1
	ok = ok and _received[0]
	manager.set_paused(true)
	ok = ok and _received.size() == 1
	manager.set_paused(false)
	ok = ok and not tree.paused
	ok = ok and not manager.is_paused()
	ok = ok and _received.size() == 2
	ok = ok and not _received[1]
	manager.queue_free()
	return ok
