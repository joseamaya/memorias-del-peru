class_name InteractionHighlight
extends Node
## Resalte suave del objeto o personaje enfocado.
##
## Escucha las señales de enfoque de su `PlayerFPS` padre y añade un material
## de superposición, un brillo aditivo tenue, a las mallas del interactuable.
## Si el interactuable no tiene mallas propias (por ejemplo, el cuerpo de
## «Hablar» de un personaje), resalta las de su padre. Al perder el foco
## restaura la superposición anterior. No conoce campañas.

const GLOW_COLOR: Color = Color(1.0, 0.92, 0.75, 0.10)

var _material: StandardMaterial3D = null
var _highlighted: Array[MeshInstance3D] = []
var _previous: Array[Material] = []


func _ready() -> void:
	_material = StandardMaterial3D.new()
	_material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	_material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	_material.blend_mode = BaseMaterial3D.BLEND_MODE_ADD
	_material.albedo_color = GLOW_COLOR
	var player: PlayerFPS = get_parent() as PlayerFPS
	if player != null:
		player.interactable_focused.connect(highlight)
		player.interactable_unfocused.connect(clear)


## Mallas que se resaltan para [param interactable].
static func meshes_for(interactable: Node) -> Array[MeshInstance3D]:
	var found: Array[MeshInstance3D] = _meshes_under(interactable)
	if found.is_empty() and interactable != null and interactable.get_parent() != null:
		found = _meshes_under(interactable.get_parent())
	return found


## Resalta [param interactable] y quita el resalte anterior.
func highlight(interactable: Interactable) -> void:
	clear()
	for mesh: MeshInstance3D in meshes_for(interactable):
		_highlighted.append(mesh)
		_previous.append(mesh.material_overlay)
		mesh.material_overlay = _material


## Quita el resalte.
func clear() -> void:
	for index: int in range(_highlighted.size()):
		var mesh: MeshInstance3D = _highlighted[index]
		if is_instance_valid(mesh):
			mesh.material_overlay = _previous[index]
	_highlighted.clear()
	_previous.clear()


## Material de superposición en uso (para las pruebas).
func glow_material() -> Material:
	return _material


static func _meshes_under(root: Node) -> Array[MeshInstance3D]:
	var result: Array[MeshInstance3D] = []
	if root == null:
		return result
	if root is MeshInstance3D and (root as MeshInstance3D).mesh != null:
		result.append(root as MeshInstance3D)
	for node: Node in root.find_children("*", "MeshInstance3D", true, false):
		var mesh: MeshInstance3D = node as MeshInstance3D
		if mesh.mesh != null and mesh.is_visible_in_tree():
			result.append(mesh)
	return result
