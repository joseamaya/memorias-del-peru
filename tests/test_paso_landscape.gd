extends RefCounted
## Comprueba el paisaje del acto II: terreno con relieve y colisión, desfiladero,
## arroyo encajado, refugio de pirca, vegetación con viento y límites.

const PASO_PATH: String = "res://campaigns/01_pachacutec/scenes/world/paso.tscn"


func _spawn() -> PasoWorld:
	var tree: SceneTree = Engine.get_main_loop() as SceneTree
	if tree == null:
		return null
	var packed: PackedScene = load(PASO_PATH) as PackedScene
	if packed == null:
		return null
	var paso: PasoWorld = packed.instantiate() as PasoWorld
	if paso == null:
		return null
	tree.root.add_child(paso)
	return paso


func test_paso_landscape() -> bool:
	var paso: PasoWorld = _spawn()
	if paso == null:
		return false
	var ok: bool = true
	# Terreno con relieve y colisión de malla.
	var terrain: Node3D = paso.get_node_or_null("Terrain") as Node3D
	var mesh_instance: MeshInstance3D = paso.get_node_or_null("Terrain/TerrainMesh") as MeshInstance3D
	var body: StaticBody3D = paso.get_node_or_null("Terrain/TerrainBody") as StaticBody3D
	ok = ok and terrain != null and mesh_instance != null and body != null
	if mesh_instance != null and mesh_instance.mesh != null:
		ok = ok and mesh_instance.mesh.get_surface_count() == 1
		var array_mesh: ArrayMesh = mesh_instance.mesh as ArrayMesh
		ok = ok and array_mesh != null and array_mesh.surface_get_array_len(0) > 20000
	ok = ok and body != null and body.get_node_or_null("TerrainCollision") is CollisionShape3D
	# El corredor es llano y las paredes suben; el arroyo queda por debajo.
	ok = ok and paso.height_at(24.0, 0.0) > paso.height_at(0.0, 0.0) + 6.0
	ok = ok and paso.height_at(0.0, 0.0) > paso.height_at(-14.0, 0.0) + 0.4
	ok = ok and paso.height_at(0.0, 30.0) < 1.0
	# El agua está por debajo de la orilla.
	var stream: MeshInstance3D = paso.get_node_or_null("Stream") as MeshInstance3D
	ok = ok and stream != null and stream.position.y < -0.3
	ok = ok and stream != null and stream.position.y > paso.height_at(-14.0, 0.0)
	# Refugio: tres muros con colisión, techo y vigas.
	var shelter: Node3D = paso.get_node_or_null("Shelter") as Node3D
	ok = ok and shelter != null
	ok = ok and shelter != null and shelter.get_node_or_null("Back") is StaticBody3D
	ok = ok and shelter != null and shelter.get_node_or_null("North") is StaticBody3D
	ok = ok and shelter != null and shelter.get_node_or_null("South") is StaticBody3D
	ok = ok and shelter != null and shelter.get_node_or_null("Roof") is MeshInstance3D
	ok = ok and paso.get_node_or_null("ShelterWalls") is MeshInstance3D
	# Vegetación: ichu y queñua con material de viento.
	var vegetation: Node3D = paso.get_node_or_null("Vegetation") as Node3D
	ok = ok and vegetation != null
	ok = ok and vegetation != null and vegetation.get_node_or_null("Ichu") != null
	ok = ok and vegetation != null and vegetation.get_node_or_null("Quenua") != null
	var ichu: Node3D = paso.get_node_or_null("Vegetation/Ichu") as Node3D
	var quenua: Node3D = paso.get_node_or_null("Vegetation/Quenua") as Node3D
	ok = ok and ichu != null and ichu.get_child_count() >= 1
	ok = ok and quenua != null and quenua.get_child_count() >= 1
	var wind: LlactaWind = paso.get_node_or_null("Wind") as LlactaWind
	ok = ok and wind != null and wind.materials.size() >= 2
	# Límites y aparición sobre el terreno.
	var bounds: Node3D = paso.get_node_or_null("Bounds") as Node3D
	ok = ok and bounds != null and bounds.get_child_count() == 4
	var player: PlayerFPS = paso.get_node_or_null("PlayerFPS") as PlayerFPS
	ok = ok and player != null and absf(player.global_position.y - (paso.height_at(0.0, 30.0) + 0.15)) < 0.2
	# La caja plana del gris ya no existe.
	ok = ok and paso.get_node_or_null("Ground") == null
	paso.free()
	return ok


func test_paso_actors_use_models() -> bool:
	var paso: PasoWorld = _spawn()
	if paso == null:
		return false
	var ok: bool = true
	for index: int in range(1, 5):
		var enemy: AmbushEnemy = paso.get_node_or_null("Ambusher%d" % index) as AmbushEnemy
		ok = ok and enemy != null
		if enemy == null:
			continue
		var visual: CharacterModelVisual = enemy.visual()
		ok = ok and visual != null and visual.model() != null
		ok = ok and visual != null and visual.model().find_child("AnimationPlayer", true, false) != null
		ok = ok and visual != null and visual.model_path.ends_with("pch_npc_commoner.glb")
		ok = ok and visual != null and visual.dark_clothes and visual.porra
		ok = ok and visual != null and visual.current_animation() == &"idle"
		ok = ok and visual != null and absf(visual.model().rotation.y) < 0.01
		ok = ok and absf(enemy.global_position.y - paso.height_at(enemy.global_position.x, enemy.global_position.z)) < 0.05
	var camp: int = 0
	for child: Node in paso.get_children():
		if child is CharacterModelVisual:
			camp += 1
			var camp_visual: CharacterModelVisual = child as CharacterModelVisual
			ok = ok and camp_visual.model() != null
			ok = ok and camp_visual.model_path.contains("pch_npc_")
	ok = ok and camp == 3
	paso.free()
	return ok
