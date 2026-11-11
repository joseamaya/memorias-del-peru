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
