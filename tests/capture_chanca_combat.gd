extends SceneTree
## Capturas del golpe y la reacción del chanca.
##
## Carga el paso, deja un solo explorador delante del jugador y congela la
## animación en cuatro momentos: anticipación, impacto, seguimiento y reacción
## al golpe. Guarda las imágenes en `user://capturas_chanca_combate/`. Sirve
## para juzgar los clips de combate, no para probar lógica.

const OUT: String = "user://capturas_chanca_combate"
const SHOTS: Array[Dictionary] = [
	{"name": "01_anticipacion", "clip": &"attack", "time": 0.30},
	{"name": "02_impacto", "clip": &"attack", "time": 0.55},
	{"name": "03_seguimiento", "clip": &"attack", "time": 0.80},
	{"name": "04_golpe", "clip": &"hit", "time": 0.18},
]

var _enemy: AmbushEnemy = null


func _initialize() -> void:
	_go.call_deferred()


func _go() -> void:
	DirAccess.make_dir_recursive_absolute(OUT)
	var paso: Node3D = (load("res://campaigns/01_pachacutec/scenes/world/paso.tscn") as PackedScene).instantiate() as Node3D
	root.add_child(paso)
	await process_frame
	var player: CharacterBody3D = paso.get_node("PlayerFPS") as CharacterBody3D
	player.process_mode = Node.PROCESS_MODE_DISABLED
	(paso.get_node("UILayer") as CanvasLayer).visible = false
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	# Un solo enemigo en el encuadre: los demás distraen al juzgar la pose.
	for other: String in ["Ambusher2", "Ambusher3", "Ambusher4"]:
		var node: Node = paso.get_node_or_null(other)
		if node != null:
			node.queue_free()
	_enemy = paso.get_node("Ambusher1") as AmbushEnemy
	_enemy.global_position = Vector3(0.0, 0.0, -1.2)
	_enemy.rotation.y = 0.0
	player.global_position = Vector3(0.0, 0.15, 2.4)
	player.rotation.y = 0.0
	var head: Node3D = player.get_node("Head") as Node3D
	head.rotation.x = -0.10
	await _frames(12)

	var visual: CharacterModelVisual = _enemy.visual()
	var player_anim: AnimationPlayer = visual.model().find_child("AnimationPlayer", true, false) as AnimationPlayer
	for shot: Dictionary in SHOTS:
		var clip: StringName = shot["clip"]
		var time: float = shot["time"]
		var shot_name: String = shot["name"]
		player_anim.play(clip)
		player_anim.speed_scale = 0.0
		player_anim.seek(time, true)
		await _frames(2)
		root.get_texture().get_image().save_png(OUT + "/" + shot_name + ".png")
	# Caída del enemigo derribado: el tween necesita tiempo real, no `seek`.
	player_anim.speed_scale = 1.0
	_enemy.take_hit(999.0)
	await create_timer(0.30).timeout
	_save("05_caida")
	await create_timer(0.45).timeout
	_save("06_en_el_suelo")
	print("CHANCA_COMBATE_OK")
	quit(0)


func _save(name: String) -> void:
	root.get_texture().get_image().save_png(OUT + "/" + name + ".png")


func _frames(count: int) -> void:
	for _i: int in range(count):
		await process_frame
