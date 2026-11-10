extends RefCounted
## Comprueba el contrato de StaminaComponent.


var _signals: int = 0
var _last_current: float = 0.0


func _on_changed(current: float, _maximum: float) -> void:
	_signals += 1
	_last_current = current


func test_stamina_contract() -> bool:
	var tree: SceneTree = Engine.get_main_loop() as SceneTree
	if tree == null:
		return false
	var stamina: StaminaComponent = StaminaComponent.new()
	stamina.max_stamina = 100.0
	stamina.regeneration_per_second = 0.0
	tree.root.add_child(stamina)
	stamina.stamina_changed.connect(_on_changed)
	var start: float = stamina.get_current()
	var consumed: float = stamina.consume(30.0)
	var after_consume: float = stamina.get_current()
	var restored: float = stamina.restore(10.0)
	var after_restore: float = stamina.get_current()
	var overflow: float = stamina.consume(500.0)
	var after_overflow: float = stamina.get_current()
	var refill: float = stamina.restore(500.0)
	var after_refill: float = stamina.get_current()
	var ok: bool = (
		is_equal_approx(start, 100.0)
		and is_equal_approx(consumed, 30.0)
		and is_equal_approx(after_consume, 70.0)
		and is_equal_approx(restored, 10.0)
		and is_equal_approx(after_restore, 80.0)
		and is_equal_approx(overflow, 80.0)
		and is_equal_approx(after_overflow, 0.0)
		and is_equal_approx(refill, 100.0)
		and is_equal_approx(after_refill, 100.0)
		and _signals == 4
		and is_equal_approx(_last_current, 100.0)
	)
	stamina.queue_free()
	return ok
