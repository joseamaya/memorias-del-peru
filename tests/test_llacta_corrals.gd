extends RefCounted
## Corrales de pirca seca (ADR-0021): existen, tienen colisión y piedras, dejan
## una entrada y no invaden los caminos ni las casas.

const WORLD_PATH: String = "res://campaigns/01_pachacutec/scenes/world/mundo_base.tscn"
## Franja de los caminos a cada lado de los ejes, como en test_llacta_layout.
const PATH_CLEAR: float = 4.5
## Distancia mínima entre el centro de una casa y el borde de un corral.
const HOUSE_CLEAR: float = 4.0


func test_llacta_corrals() -> bool:
	var tree: SceneTree = Engine.get_main_loop() as SceneTree
	if tree == null:
		return false
	var world: Node = (load(WORLD_PATH) as PackedScene).instantiate()
	tree.root.add_child(world)
	var corrals: Node3D = world.get_node_or_null("Llacta/Corrals") as Node3D
	var houses: Node3D = world.get_node_or_null("Llacta/Houses") as Node3D
	var ok: bool = corrals != null and houses != null and corrals.get_child_count() == MundoBase.CORRALS.size()
	if not ok:
		world.free()
		return false
	for index: int in range(MundoBase.CORRALS.size()):
		var entry: Array = MundoBase.CORRALS[index]
		var center: Vector3 = entry[0]
		var size: Vector2 = entry[1]
		var area: Rect2 = Rect2(Vector2(center.x, center.z) - size * 0.5, size)
		var corral: Node3D = corrals.get_child(index) as Node3D
		var walls: int = 0
		for child: Node in corral.get_children():
			if child is StaticBody3D:
				walls += 1
		# Cuatro lados y uno partido por la entrada.
		ok = ok and walls == 5
		var stones: MeshInstance3D = corral.get_node_or_null("Stones") as MeshInstance3D
		ok = ok and stones != null and stones.mesh != null and stones.mesh.get_faces().size() > 600
		# Fuera de la franja de los caminos.
		ok = ok and minf(absf(area.position.x), absf(area.end.x)) > PATH_CLEAR and signf(area.position.x) == signf(area.end.x)
		ok = ok and minf(absf(area.position.y), absf(area.end.y)) > PATH_CLEAR and signf(area.position.y) == signf(area.end.y)
		for house: Node in houses.get_children():
			var at: Vector3 = (house as Node3D).position
			ok = ok and not area.grow(HOUSE_CLEAR).has_point(Vector2(at.x, at.z))
	world.free()
	return ok
