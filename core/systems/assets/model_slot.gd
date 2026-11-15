class_name ModelSlot
extends Node3D
## Hueco para un modelo definitivo con respaldo al bloqueo.
##
## Al entrar en el árbol carga el primer archivo de [member model_paths] que
## exista (normalmente un `.glb` importado) como hijo propio y oculta los nodos
## de bloqueo. Si no existe ninguno, no hace nada y el bloqueo sigue a la vista:
## cada asset entra en cuanto se añade su archivo, sin tocar escenas ni lógica.
## No conoce campañas ni nombres de archivo concretos.

signal model_loaded(model: Node3D)

## Rutas candidatas, de la más específica a la más genérica.
@export var model_paths: Array[String] = []
## Nodos visuales del bloqueo que se ocultan al cargar el modelo. Si el hueco
## es descendiente de uno de ellos (por ejemplo, para heredar sus animaciones),
## a ese nodo se le quita la malla en lugar de ocultarlo.
@export var blockout_nodes: Array[Node3D] = []
## Colisiones del bloqueo que se eliminan solo si el modelo trae colisión.
@export var blockout_collisions: Array[Node] = []
## Si es `false`, se conserva siempre la colisión del bloqueo.
@export var use_model_collision: bool = true

var model: Node3D = null
var loaded_path: String = ""


func _ready() -> void:
	load_model()


## Primera ruta de [param paths] que existe como recurso, o cadena vacía.
static func first_existing(paths: Array[String]) -> String:
	for path: String in paths:
		if not path.is_empty() and ResourceLoader.exists(path):
			return path
	return ""


## Indica si [param root] o algún descendiente es una forma de colisión.
static func has_collision(root: Node) -> bool:
	if root == null:
		return false
	if root is CollisionShape3D:
		return true
	return not root.find_children("*", "CollisionShape3D", true, false).is_empty()


## Activa el color por vértice como albedo en cada superficie de [param mesh]
## que lo trae. Los modelos sin material propio (como los que genera el script
## de Blender, ADR-0010) llegan del importador glTF con un material que ignora
## ese color. Devuelve cuántas superficies se ajustaron.
static func enable_vertex_colors(mesh: Mesh) -> int:
	var array_mesh: ArrayMesh = mesh as ArrayMesh
	if array_mesh == null:
		return 0
	var changed: int = 0
	for surface: int in range(array_mesh.get_surface_count()):
		if (array_mesh.surface_get_format(surface) & Mesh.ARRAY_FORMAT_COLOR) == 0:
			continue
		var material: BaseMaterial3D = array_mesh.surface_get_material(surface) as BaseMaterial3D
		if material == null:
			if array_mesh.surface_get_material(surface) != null:
				continue
			material = StandardMaterial3D.new()
			array_mesh.surface_set_material(surface, material)
		if not material.vertex_color_use_as_albedo:
			material.vertex_color_use_as_albedo = true
			changed += 1
	return changed


## [method enable_vertex_colors] en todas las mallas bajo [param root].
static func enable_vertex_colors_in(root: Node) -> int:
	var changed: int = 0
	var nodes: Array[Node] = root.find_children("*", "MeshInstance3D", true, false)
	if root is MeshInstance3D:
		nodes.append(root)
	for node: Node in nodes:
		changed += enable_vertex_colors((node as MeshInstance3D).mesh)
	return changed


## Altura visible de [param root] en su espacio local, o 0 si no tiene mallas.
static func visible_height(root: Node3D) -> float:
	if root == null:
		return 0.0
	var bounds: AABB = visible_bounds(root)
	return bounds.size.y if bounds.size.y > 0.0 else 0.0


## Caja que ocupan las mallas de [param root] en su espacio local.
static func visible_bounds(root: Node3D) -> AABB:
	var bounds: AABB = AABB()
	var first: bool = true
	if root == null:
		return bounds
	var nodes: Array[Node] = root.find_children("*", "MeshInstance3D", true, false)
	if root is MeshInstance3D:
		nodes.append(root)
	for node: Node in nodes:
		var mesh_instance: MeshInstance3D = node as MeshInstance3D
		if mesh_instance == null or mesh_instance.mesh == null:
			continue
		var box: AABB = mesh_instance.transform * mesh_instance.get_aabb()
		if first:
			bounds = box
			first = false
		else:
			bounds = bounds.merge(box)
	return bounds


## Ajusta [param root] para que su altura visible sea [param target_height] y
## sus pies queden en el origen del hueco. Con [param target_height] en 0 solo
## se apoya en el suelo, sin escalar: sirve para las posturas sentadas.
## Devuelve la escala aplicada.
static func fit_height(root: Node3D, target_height: float, ground_offset: float = 0.0) -> float:
	if root == null:
		return 1.0
	var bounds: AABB = visible_bounds(root)
	if bounds.size.y <= 0.01:
		return 1.0
	var factor: float = 1.0
	if target_height > 0.0:
		factor = target_height / bounds.size.y
	root.scale = Vector3.ONE * factor
	root.position.y = -bounds.position.y * factor + ground_offset
	return factor


## Carga el modelo si existe. Devuelve `true` si hay un modelo cargado.
## Las llamadas repetidas no lo duplican.
func load_model() -> bool:
	if model != null:
		return true
	var path: String = first_existing(model_paths)
	if path.is_empty():
		return false
	var packed: PackedScene = load(path) as PackedScene
	if packed == null:
		return false
	var instance: Node = packed.instantiate()
	var instance_3d: Node3D = instance as Node3D
	if instance_3d == null:
		instance.free()
		return false
	instance_3d.name = "Model"
	enable_vertex_colors_in(instance_3d)
	add_child(instance_3d)
	model = instance_3d
	loaded_path = path
	_hide_blockout()
	if use_model_collision and has_collision(instance_3d):
		for collision: Node in blockout_collisions:
			if collision != null and is_instance_valid(collision):
				collision.queue_free()
	model_loaded.emit(instance_3d)
	return true


func _hide_blockout() -> void:
	for node: Node3D in blockout_nodes:
		if node == null or not is_instance_valid(node):
			continue
		if node.is_ancestor_of(self) and node is MeshInstance3D:
			(node as MeshInstance3D).mesh = null
		else:
			node.visible = false
