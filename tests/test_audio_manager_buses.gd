extends RefCounted
## Comprueba que AudioManager crea el bus de efectos.


func test_audio_manager_buses() -> bool:
	var tree: SceneTree = Engine.get_main_loop() as SceneTree
	if tree == null:
		return false
	var manager: AudioManagerService = AudioManagerService.new()
	tree.root.add_child(manager)
	var ok: bool = AudioServer.get_bus_index(&"SFX") >= 0
	manager.queue_free()
	return ok
