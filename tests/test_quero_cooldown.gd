extends RefCounted
## Comprueba el tiempo de espera del quero.


func test_quero_cooldown() -> bool:
	var tree: SceneTree = Engine.get_main_loop() as SceneTree
	if tree == null:
		return false
	var interactor: Node3D = Node3D.new()
	var stamina: StaminaComponent = StaminaComponent.new()
	stamina.max_stamina = 100.0
	stamina.regeneration_per_second = 0.0
	interactor.add_child(stamina)
	tree.root.add_child(interactor)
	stamina.consume(1000.0)
	var quero: QueroChicha = QueroChicha.new()
	quero.restore_amount = 35.0
	quero.cooldown_seconds = 10.0
	quero.interact(interactor)
	var after_first: float = stamina.get_current()
	quero.interact(interactor)
	var after_second: float = stamina.get_current()
	quero.tick_cooldown(10.0)
	quero.interact(interactor)
	var after_third: float = stamina.get_current()
	var ok: bool = (
		is_equal_approx(after_first, 35.0)
		and is_equal_approx(after_second, 35.0)
		and is_equal_approx(after_third, 70.0)
	)
	quero.free()
	interactor.free()
	return ok
