extends RefCounted
## Comprueba las capas de cielo del mundo: la cúpula de nubes procedurales y
## las dos siluetas de cordillera lejana. Son solo visuales: no deben añadir
## colisión ni afectar al límite jugable.

const WORLD_PATH: String = "res://campaigns/01_pachacutec/scenes/world/mundo_base.tscn"
const RANGE_NAMES: Array[String] = ["DistantRangeNear", "DistantRangeMid", "DistantRangeFar"]


func test_world_sky_layers() -> bool:
	var tree: SceneTree = Engine.get_main_loop() as SceneTree
	if tree == null:
		return false
	var world: Node = (load(WORLD_PATH) as PackedScene).instantiate()
	tree.root.add_child(world)
	var dome: MeshInstance3D = world.get_node_or_null("CloudDome") as MeshInstance3D
	if dome == null:
		world.free()
		return false
	var cloud_material: ShaderMaterial = dome.material_override as ShaderMaterial
	var ok: bool = (
		dome.mesh is SphereMesh
		and cloud_material != null
		and cloud_material.shader != null
		and dome.find_children("*", "CollisionShape3D", true, false).is_empty()
	)
	for range_name: String in RANGE_NAMES:
		var range_node: MeshInstance3D = world.get_node_or_null(range_name) as MeshInstance3D
		if range_node == null or range_node.mesh == null:
			ok = false
			continue
		var material: StandardMaterial3D = range_node.material_override as StandardMaterial3D
		ok = ok and range_node.mesh.get_surface_count() > 0
		ok = ok and material != null
		if material != null:
			ok = ok and material.shading_mode == BaseMaterial3D.SHADING_MODE_UNSHADED
		ok = ok and range_node.find_children("*", "CollisionShape3D", true, false).is_empty()
	world.free()
	return ok
