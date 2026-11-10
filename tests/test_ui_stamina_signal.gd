extends RefCounted
## Comprueba que el HUD reacciona a la señal de estamina.


func test_ui_stamina_signal() -> bool:
	var tree: SceneTree = Engine.get_main_loop() as SceneTree
	if tree == null:
		return false
	var stamina: StaminaComponent = StaminaComponent.new()
	stamina.max_stamina = 100.0
	stamina.regeneration_per_second = 0.0
	tree.root.add_child(stamina)
	var packed: PackedScene = load("res://core/ui/hud.tscn") as PackedScene
	var hud: PlayerHud = packed.instantiate() as PlayerHud
	hud.stamina = stamina
	tree.root.add_child(hud)
	stamina.consume(25.0)
	var ok: bool = is_equal_approx(hud.stamina_bar.value, 75.0) and hud.stamina_bar.visible
	stamina.restore(25.0)
	ok = ok and not hud.stamina_bar.visible
	hud.queue_free()
	stamina.queue_free()
	return ok
