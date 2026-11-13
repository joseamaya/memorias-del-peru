extends RefCounted
## Comprueba que el mundo arranca con un objetivo visible y que la primera
## interacción lo hace avanzar. Es la respuesta permanente a «¿qué hago?».

const WORLD_PATH: String = "res://campaigns/01_pachacutec/scenes/world/mundo_base.tscn"


func _spawn_world() -> Node:
	var tree: SceneTree = Engine.get_main_loop() as SceneTree
	if tree == null:
		return null
	var packed: PackedScene = load(WORLD_PATH) as PackedScene
	if packed == null:
		return null
	var world: Node = packed.instantiate()
	tree.root.add_child(world)
	return world


func test_world_objective_starts_with_quero() -> bool:
	var world: Node = _spawn_world()
	if world == null:
		return false
	var hud: PlayerHud = world.get_node_or_null("UILayer/HUD") as PlayerHud
	var ok: bool = (
		hud != null
		and world.call("get_objective") == MundoBase.Objective.QUERO
		and hud.is_showing_objective()
		and hud.get_objective_text() == tr("PCH_OBJ_QUERO")
	)
	world.free()
	return ok


func test_world_objective_advances_with_quero() -> bool:
	var world: Node = _spawn_world()
	if world == null:
		return false
	var quero: QueroChicha = world.get_node_or_null("QueroChicha") as QueroChicha
	var player: PlayerFPS = world.get_node_or_null("PlayerFPS") as PlayerFPS
	var hud: PlayerHud = world.get_node_or_null("UILayer/HUD") as PlayerHud
	var ok: bool = quero != null and player != null and hud != null
	if ok:
		# Sin audio en la prueba: el objeto debe avanzar el objetivo por señal.
		quero.audio_stream = null
		quero.interact(player)
		ok = world.call("get_objective") == MundoBase.Objective.OFFERING
		ok = ok and hud.get_objective_text() == tr("PCH_OBJ_OFFERING")
	world.free()
	return ok
