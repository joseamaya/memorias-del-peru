extends RefCounted
## Comprueba que las terrazas son macizas: los bloques llegan al suelo, bajo
## cada rampa elevada hay relleno hasta su arranque y una tapa cierra el
## extremo alto. Antes, los niveles 2 y 3 flotaban y el jugador podía quedarse
## encajado bajo la rampa entrando desde el este.

const WORLD_PATH: String = "res://campaigns/01_pachacutec/scenes/world/mundo_base.tscn"
const LEVELS: Array[String] = ["Terrace01", "Terrace02", "Terrace03"]
const TOLERANCE: float = 0.01


## Altura de la base (y mínima) de la caja de colisión de un cuerpo.
func _bottom_of(body: StaticBody3D) -> float:
	for child: Node in body.get_children():
		var shape_node: CollisionShape3D = child as CollisionShape3D
		if shape_node == null:
			continue
		var box: BoxShape3D = shape_node.shape as BoxShape3D
		if box != null:
			return body.global_position.y + shape_node.position.y - box.size.y * 0.5
	return INF


func test_terraces_solid() -> bool:
	var tree: SceneTree = Engine.get_main_loop() as SceneTree
	if tree == null:
		return false
	var world: Node = (load(WORLD_PATH) as PackedScene).instantiate()
	tree.root.add_child(world)
	var ok: bool = true
	for index: int in range(LEVELS.size()):
		var level: String = LEVELS[index]
		for part: String in ["North", "South", "Cap"]:
			var body: StaticBody3D = world.get_node_or_null("Llacta/Terraces/%s%s" % [level, part]) as StaticBody3D
			ok = ok and body != null and absf(_bottom_of(body)) < TOLERANCE
		var fill: StaticBody3D = world.get_node_or_null("Llacta/Terraces/%sFill" % level) as StaticBody3D
		if index == 0:
			# La primera rampa arranca en el suelo: no necesita relleno.
			ok = ok and fill == null
		else:
			ok = ok and fill != null and absf(_bottom_of(fill)) < TOLERANCE
	world.free()
	return ok
