extends SceneTree
## Prueba de humo del acto II en gris: la honda acierta, los enemigos atacan y
## el jugador pierde salud. No forma parte del ejecutor de pruebas.
##
## Uso: godot --headless --path . --script res://tests/paso_smoke.gd

const PASO_PATH: String = "res://campaigns/01_pachacutec/scenes/world/paso.tscn"


func _initialize() -> void:
	_run.call_deferred()


func _run() -> void:
	var paso: Node = (load(PASO_PATH) as PackedScene).instantiate()
	root.add_child(paso)
	await process_frame
	var player: CharacterBody3D = paso.get_node("PlayerFPS") as CharacterBody3D
	paso.call("_start_ambush")
	var enemy: Node3D = paso.get_node("Ambusher1") as Node3D
	player.global_position = enemy.global_position + Vector3(0.0, 0.0, 5.0)
	player.look_at(enemy.global_position, Vector3.UP)
	await physics_frame
	var before: Variant = (enemy.get_node("CharacterState") as Node).call("get_health")
	paso.call("_attack")
	var after: Variant = (enemy.get_node("CharacterState") as Node).call("get_health")
	for _i: int in range(180):
		await physics_frame
	var health: Variant = (paso.get_node("PlayerFPS/CharacterState") as Node).call("get_health")
	print("PASO_SMOKE hit=", before, "->", after, " health=", health, " alive=", paso.call("alive_enemies"))
	quit(0)
