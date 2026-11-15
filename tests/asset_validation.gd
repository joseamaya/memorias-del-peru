class_name AssetValidation
extends RefCounted
## Reglas de los modelos definitivos (reglas de los modelos definitivos, §7).
##
## Auxiliar de las pruebas: el ejecutor solo carga `test_*.gd`, así que este
## archivo se usa con preload(). Trabaja sobre la escena ya instanciada, de modo
## que sirve igual para un `.glb` importado que para uno generado en memoria.

const NAME_PATTERN: String = "^pch_[a-z0-9]+(_[a-z0-9]+)*\\.glb$"
const MIN_SIZE: float = 0.05
const MAX_SIZE: float = 20.0
const BASE_TOLERANCE: float = 0.05
const SCALE_TOLERANCE: float = 0.001
const NPC_MIN_HEIGHT: float = 1.2
const NPC_MAX_HEIGHT: float = 2.1
## Prefijos de modelos que deben traer su propia colisión (mallas `-col`).
const COLLISION_REQUIRED_PREFIXES: Array[String] = ["pch_house_"]
const NPC_PREFIX: String = "pch_npc_"


## Errores de nombre de archivo (vacío si es válido).
static func validate_file_name(file_name: String) -> PackedStringArray:
	var errors: PackedStringArray = PackedStringArray()
	var regex: RegEx = RegEx.create_from_string(NAME_PATTERN)
	if regex.search(file_name) == null:
		errors.append("%s: el nombre debe ser snake_case con prefijo pch_ y extensión .glb" % file_name)
	return errors


## Transformación de [param node] relativa a [param root], sin necesidad de que
## la escena esté en el árbol.
static func transform_to_root(node: Node3D, root: Node3D) -> Transform3D:
	var result: Transform3D = Transform3D.IDENTITY
	var current: Node = node
	while current != null and current != root:
		var current_3d: Node3D = current as Node3D
		if current_3d != null:
			result = current_3d.transform * result
		current = current.get_parent()
	return result


## Caja que envuelve todas las mallas visibles, en el espacio de [param root].
## Devuelve una caja de tamaño cero si no hay mallas.
static func visual_bounds(root: Node3D) -> AABB:
	var meshes: Array[Node] = root.find_children("*", "MeshInstance3D", true, false)
	if root is MeshInstance3D:
		meshes.append(root)
	var bounds: AABB = AABB()
	var first: bool = true
	for node: Node in meshes:
		var mesh_instance: MeshInstance3D = node as MeshInstance3D
		if mesh_instance.mesh == null:
			continue
		var box: AABB = transform_to_root(mesh_instance, root) * mesh_instance.get_aabb()
		bounds = box if first else bounds.merge(box)
		first = false
	return bounds


## Errores de contenido del modelo instanciado [param root] llamado
## [param file_name] (vacío si cumple todas las reglas).
static func validate_model(root: Node3D, file_name: String) -> PackedStringArray:
	var errors: PackedStringArray = validate_file_name(file_name)
	var bounds: AABB = visual_bounds(root)
	if bounds.size == Vector3.ZERO:
		errors.append("%s: no contiene mallas visibles" % file_name)
		return errors
	var largest: float = maxf(bounds.size.x, maxf(bounds.size.y, bounds.size.z))
	if largest < MIN_SIZE or largest > MAX_SIZE:
		errors.append("%s: tamaño máximo %.2f m fuera de [%.2f, %.1f]; ¿escala en metros?" % [file_name, largest, MIN_SIZE, MAX_SIZE])
	if absf(bounds.position.y) > BASE_TOLERANCE:
		errors.append("%s: la base está a %.2f m del origen; el origen debe estar en la base" % [file_name, bounds.position.y])
	var nodes: Array[Node] = root.find_children("*", "Node3D", true, false)
	nodes.append(root)
	for node: Node in nodes:
		var node_3d: Node3D = node as Node3D
		var scale: Vector3 = node_3d.transform.basis.get_scale()
		if not scale.is_equal_approx(Vector3.ONE) and (scale - Vector3.ONE).length() > SCALE_TOLERANCE:
			errors.append("%s: el nodo %s tiene escala %s; aplicar transformaciones en Blender" % [file_name, node_3d.name, scale])
			break
	var has_collision: bool = not root.find_children("*", "CollisionShape3D", true, false).is_empty()
	for prefix: String in COLLISION_REQUIRED_PREFIXES:
		if file_name.begins_with(prefix) and not has_collision:
			errors.append("%s: necesita colisión propia (malla con sufijo -col)" % file_name)
	if file_name.begins_with(NPC_PREFIX):
		if bounds.size.y < NPC_MIN_HEIGHT or bounds.size.y > NPC_MAX_HEIGHT:
			errors.append("%s: altura %.2f m fuera de [%.1f, %.1f]" % [file_name, bounds.size.y, NPC_MIN_HEIGHT, NPC_MAX_HEIGHT])
		if has_collision:
			errors.append("%s: los personajes no traen colisión; se usa la cápsula de la escena" % file_name)
	return errors
