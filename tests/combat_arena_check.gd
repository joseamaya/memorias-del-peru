extends SceneTree
## Comprobación de comportamiento del combate: tres chancas contra un bot.
##
##   godot --headless --path . --script res://tests/combat_arena_check.gd
##
## No sustituye a las pruebas unitarias: comprueba que el encuentro termina,
## que nunca hay más de dos atacantes a la vez y que el jugador sigue vivo.

const ARENA: String = "res://tests/scenes/combat_arena.tscn"
const MAX_FRAMES: int = 2400


func _initialize() -> void:
	_run.call_deferred()


func _run() -> void:
	var packed: PackedScene = load(ARENA) as PackedScene
	if packed == null:
		printerr("COMBAT_ARENA_FAIL no se pudo cargar la arena")
		quit(1)
		return
	var arena: CombatArenaCheck = packed.instantiate() as CombatArenaCheck
	root.add_child(arena)
	var frames: int = 0
	while frames < MAX_FRAMES:
		await physics_frame
		frames += 1
		if arena.is_finished():
			break
	var resolved: int = arena.resolved_count()
	var max_attackers: int = arena.max_attackers()
	var alive: bool = arena.player_alive()
	var ok: bool = alive
	ok = ok and resolved >= 2
	ok = ok and max_attackers >= 1
	ok = ok and max_attackers <= 2
	print("COMBAT_ARENA frames=%d resolved=%d max_attackers=%d player_alive=%s"
		% [frames, resolved, max_attackers, str(alive)])
	print("COMBAT_ARENA_OK" if ok else "COMBAT_ARENA_FAIL")
	_stop_audio(arena)
	arena.queue_free()
	await process_frame
	await process_frame
	# Deja que el hilo de audio suelte la reproducción antes de salir.
	await create_timer(0.25).timeout
	quit(0 if ok else 1)


func _stop_audio(root_node: Node) -> void:
	# Congela el árbol antes de parar: la respiración se reprograma sola desde
	# `_process` y volvería a sonar entre el stop y el free.
	root_node.process_mode = Node.PROCESS_MODE_DISABLED
	for node: Node in root_node.find_children("*", "AudioStreamPlayer", true, false):
		(node as AudioStreamPlayer).stop()
	for node: Node in root_node.find_children("*", "AudioStreamPlayer3D", true, false):
		(node as AudioStreamPlayer3D).stop()
