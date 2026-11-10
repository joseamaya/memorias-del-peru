extends RefCounted
## Comprueba que el quero restaura estamina sin conocer la UI.


func test_quero_restores_stamina() -> bool:
	var tree: SceneTree = Engine.get_main_loop() as SceneTree
	if tree == null:
		return false
	var interactor: Node3D = Node3D.new()
	var stamina: StaminaComponent = StaminaComponent.new()
	stamina.max_stamina = 100.0
	stamina.regeneration_per_second = 0.0
	interactor.add_child(stamina)
	tree.root.add_child(interactor)
	stamina.consume(50.0)
	var quero: QueroChicha = QueroChicha.new()
	quero.restore_amount = 35.0
	quero.interact(interactor)
	var ok: bool = is_equal_approx(stamina.get_current(), 85.0)
	quero.free()
	interactor.free()
	return ok
