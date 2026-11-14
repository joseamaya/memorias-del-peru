extends RefCounted
## Comprueba ModelSlot: sin archivo conserva el bloqueo; con archivo carga el
## modelo, oculta el bloqueo, quita la malla del padre si cuelga de él y solo
## sustituye la colisión si el modelo trae la suya. Comprueba además que el
## mundo tiene un hueco en cada casa, personaje y objeto, y que el color por
## vértice de los modelos generados se activa al cargarlos.

const FIXTURE_PATH: String = "user://test_model_slot_fixture.tscn"
const WORLD_PATH: String = "res://campaigns/01_pachacutec/scenes/world/mundo_base.tscn"


func _save_fixture(with_collision: bool) -> bool:
	var root: Node3D = Node3D.new()
	root.name = "Fixture"
	var mesh_instance: MeshInstance3D = MeshInstance3D.new()
	mesh_instance.mesh = BoxMesh.new()
	root.add_child(mesh_instance)
	mesh_instance.owner = root
	if with_collision:
		var body: StaticBody3D = StaticBody3D.new()
		root.add_child(body)
		body.owner = root
		var shape: CollisionShape3D = CollisionShape3D.new()
		shape.shape = BoxShape3D.new()
		body.add_child(shape)
		shape.owner = root
	var packed: PackedScene = PackedScene.new()
	var ok: bool = packed.pack(root) == OK and ResourceSaver.save(packed, FIXTURE_PATH) == OK
	root.free()
	return ok


func _slot_case(tree: SceneTree, paths: Array[String], with_collision: bool) -> Dictionary[String, bool]:
	var holder: Node3D = Node3D.new()
	var blockout: MeshInstance3D = MeshInstance3D.new()
	blockout.mesh = BoxMesh.new()
	holder.add_child(blockout)
	var collision: CollisionShape3D = CollisionShape3D.new()
	holder.add_child(collision)
	var parent_mesh: MeshInstance3D = MeshInstance3D.new()
	parent_mesh.mesh = BoxMesh.new()
	holder.add_child(parent_mesh)
	var slot: ModelSlot = ModelSlot.new()
	slot.model_paths = paths
	var blockout_nodes: Array[Node3D] = [blockout, parent_mesh]
	slot.blockout_nodes = blockout_nodes
	var collisions: Array[Node] = [collision]
	slot.blockout_collisions = collisions
	parent_mesh.add_child(slot)
	_save_fixture(with_collision)
	tree.root.add_child(holder)
	var result: Dictionary[String, bool] = {
		"loaded": slot.model != null,
		"blockout_visible": blockout.visible,
		"parent_mesh_kept": parent_mesh.mesh != null and parent_mesh.visible,
		"collision_removed": collision.is_queued_for_deletion(),
		"second_load_no_duplicate": slot.load_model() and slot.get_child_count() == (1 if slot.model != null else 0),
	}
	holder.free()
	return result


func test_model_slot() -> bool:
	var tree: SceneTree = Engine.get_main_loop() as SceneTree
	if tree == null:
		return false
	var ok: bool = true
	ok = ok and ModelSlot.first_existing(["res://no_existe.glb", ""]) == ""
	# Sin archivo: el bloqueo queda intacto.
	var missing: Array[String] = ["res://no_existe.glb"]
	var none: Dictionary[String, bool] = _slot_case(tree, missing, true)
	ok = ok and not none["loaded"] and none["blockout_visible"] and none["parent_mesh_kept"]
	ok = ok and not none["collision_removed"]
	# Con archivo sin colisión: modelo cargado, bloqueo oculto, colisión intacta.
	var present: Array[String] = ["res://no_existe.glb", FIXTURE_PATH]
	var plain: Dictionary[String, bool] = _slot_case(tree, present, false)
	ok = ok and plain["loaded"] and not plain["blockout_visible"]
	ok = ok and not plain["parent_mesh_kept"] and not plain["collision_removed"]
	ok = ok and plain["second_load_no_duplicate"]
	# Con archivo con colisión: se elimina la colisión del bloqueo.
	var solid: Dictionary[String, bool] = _slot_case(tree, present, true)
	ok = ok and solid["loaded"] and solid["collision_removed"]
	DirAccess.remove_absolute(ProjectSettings.globalize_path(FIXTURE_PATH))

	# Huecos del mundo: 8 casas, 9 personajes, 3 objetos y el telar.
	var world: Node = (load(WORLD_PATH) as PackedScene).instantiate()
	tree.root.add_child(world)
	var slots: Array[Node] = world.find_children("*", "ModelSlot", true, false)
	var by_parent: Dictionary[String, int] = {"house": 0, "npc": 0, "object": 0, "loom": 0}
	var props: int = 0
	for node: Node in slots:
		var slot: ModelSlot = node as ModelSlot
		var parent: Node = slot.get_parent()
		var actor: Node = parent.get_parent()
		if parent.is_in_group("houses") and String(slot.name).begins_with("Prop"):
			props += 1
		elif parent.is_in_group("houses"):
			by_parent["house"] += 1
		elif actor != null and actor.is_in_group("npcs"):
			# El hueco del personaje cuelga de su cuerpo para heredar el
			# balanceo; sus pies quedan en el origen del personaje.
			by_parent["npc"] += 1
			ok = ok and slot.global_position.distance_to((actor as Node3D).global_position) < 0.001
		elif slot.name == "LoomSlot":
			by_parent["loom"] += 1
		elif parent is MeshInstance3D:
			by_parent["object"] += 1
		for path: String in slot.model_paths:
			ok = ok and AssetValidation.validate_file_name(path.get_file()).is_empty()
	ok = ok and by_parent["house"] == 8 and by_parent["npc"] == 9
	# Props junto a las casas: cántaros y leña (PCH-019 y PCH-020).
	ok = ok and props >= 8
	ok = ok and _vertex_colors_enabled()
	ok = ok and by_parent["object"] == 3 and by_parent["loom"] == 1
	world.free()
	return ok


## Una malla con color por vértice y sin material propio queda con el color
## como albedo tras pasar por ModelSlot.enable_vertex_colors().
func _vertex_colors_enabled() -> bool:
	var arrays: Array = []
	arrays.resize(Mesh.ARRAY_MAX)
	arrays[Mesh.ARRAY_VERTEX] = PackedVector3Array([Vector3.ZERO, Vector3.RIGHT, Vector3.UP])
	arrays[Mesh.ARRAY_COLOR] = PackedColorArray([Color.RED, Color.RED, Color.RED])
	var mesh: ArrayMesh = ArrayMesh.new()
	mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arrays)
	var plain: ArrayMesh = ArrayMesh.new()
	var plain_arrays: Array = []
	plain_arrays.resize(Mesh.ARRAY_MAX)
	plain_arrays[Mesh.ARRAY_VERTEX] = PackedVector3Array([Vector3.ZERO, Vector3.RIGHT, Vector3.UP])
	plain.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, plain_arrays)
	var changed: int = ModelSlot.enable_vertex_colors(mesh)
	var material: BaseMaterial3D = mesh.surface_get_material(0) as BaseMaterial3D
	var ok: bool = changed == 1 and material != null and material.vertex_color_use_as_albedo
	ok = ok and ModelSlot.enable_vertex_colors(mesh) == 0
	ok = ok and ModelSlot.enable_vertex_colors(plain) == 0 and plain.surface_get_material(0) == null
	return ok
