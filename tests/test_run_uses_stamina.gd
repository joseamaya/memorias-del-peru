extends RefCounted
## Comprueba las reglas de carrera con estamina.


func test_run_uses_stamina() -> bool:
	var tree: SceneTree = Engine.get_main_loop() as SceneTree
	if tree == null:
		return false
	var player: PlayerFPS = PlayerFPS.new()
	var stamina: StaminaComponent = StaminaComponent.new()
	stamina.max_stamina = 100.0
	stamina.regeneration_per_second = 0.0
	tree.root.add_child(stamina)
	player.stamina = stamina
	var ran: bool = player.update_run_state(true, true, 1.0)
	var after_run: float = stamina.get_current()
	stamina.consume(1000.0)
	var blocked: bool = not player.update_run_state(true, true, 1.0)
	stamina.restore(25.0)
	var resumed: bool = player.update_run_state(true, true, 1.0)
	var idle: bool = not player.update_run_state(false, true, 1.0)
	var ok: bool = (
		ran
		and is_equal_approx(after_run, 85.0)
		and blocked
		and resumed
		and idle
		and is_equal_approx(stamina.get_current(), 10.0)
	)
	player.free()
	stamina.queue_free()
	return ok
