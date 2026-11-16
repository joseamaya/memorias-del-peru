extends RefCounted
## Comprueba que un punto de conversación sin malla no resalta el mundo entero
## y que un target explícito sigue funcionando.


func test_camp_point_highlight_is_scoped() -> bool:
	var tree: SceneTree = Engine.get_main_loop() as SceneTree
	if tree == null:
		return false
	var world: Node3D = Node3D.new()
	var scene_mesh: MeshInstance3D = MeshInstance3D.new()
	scene_mesh.mesh = BoxMesh.new()
	world.add_child(scene_mesh)
	var camp: CampPoint = CampPoint.new()
	camp.name = "CampPoint"
	world.add_child(camp)
	tree.root.add_child(world)
	var ok: bool = not camp.highlight_parent_if_empty
	ok = ok and InteractionHighlight.meshes_for(camp).is_empty()

	var target: Node3D = Node3D.new()
	var target_mesh: MeshInstance3D = MeshInstance3D.new()
	target_mesh.mesh = BoxMesh.new()
	target.add_child(target_mesh)
	world.add_child(target)
	camp.highlight_target = target
	var found: Array[MeshInstance3D] = InteractionHighlight.meshes_for(camp)
	ok = ok and found.size() == 1 and found[0] == target_mesh

	world.free()
	return ok
