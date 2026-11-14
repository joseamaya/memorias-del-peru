class_name CharacterModelVisual
extends Node3D
## Visual de un personaje MakeHuman/Rocketbox ya versionado.
##
## Carga el GLB con un [ModelSlot], aplica los materiales del proyecto y
## reproduce su reposo. Puede oscurecer la ropa y añadir una porra para los
## chancas. No conoce la lógica: los puntos de interacción y la colisión viven
## fuera. El modelo mira hacia -Z, como el actor, así que no se gira.

## Tinte de la ropa oscura de los chancas; multiplica el tejido original.
const DARK_CLOTH_TINT: Color = Color(0.30, 0.26, 0.23, 1.0)

@export var model_path: String = ""
@export var idle_clip: StringName = &"idle"
@export var dark_clothes: bool = false
@export var porra: bool = false

var _slot: ModelSlot = null
var _model: Node3D = null
var _player: AnimationPlayer = null
var _porra_pivot: Node3D = null
var _skeleton: Skeleton3D = null
var _hand_index: int = -1


func _ready() -> void:
	if model_path.is_empty() or not ResourceLoader.exists(model_path):
		return
	_slot = ModelSlot.new()
	_slot.name = "ModelSlot"
	_slot.model_paths = [model_path]
	add_child(_slot)
	_model = _slot.model
	if _model == null:
		return
	# Bajo el driver Dummy de las pruebas sin pantalla, los overrides de
	# material se liberan mal; en el juego y en las capturas sí se aplican.
	if DisplayServer.get_name() != "headless":
		SurfaceMaterials.apply_to_model(_model)
	_player = _model.find_child("AnimationPlayer", true, false) as AnimationPlayer
	if _player != null and _player.has_animation(idle_clip):
		_player.play(idle_clip)
	if dark_clothes:
		_darken_clothes()
	if porra:
		_build_porra()


## Reproduce un clip lógico (`Walk`, `Idle`, `Sword_Attack`, `Hit_Chest`) con
## el nombre propio del modelo. Si no existe, cae a un clip equivalente.
func play(clip: StringName, speed: float = 1.0) -> void:
	if _player == null:
		return
	var mapped: StringName = clip
	if not _player.has_animation(mapped):
		match clip:
			&"Walk":
				mapped = &"walk"
			&"Run":
				mapped = &"run"
			&"Idle":
				mapped = &"idle"
			&"Sword_Attack":
				mapped = &"idle"
			&"Hit_Chest":
				mapped = &"tired"
			_:
				mapped = &"idle"
	if not _player.has_animation(mapped):
		return
	_player.play(mapped, 0.2, speed)
	if clip == &"Sword_Attack" and _porra_pivot != null:
		var tween: Tween = create_tween()
		tween.tween_property(_porra_pivot, "rotation_degrees:x", -80.0, 0.12)
		tween.tween_property(_porra_pivot, "rotation_degrees:x", -20.0, 0.18)


## Nodo del modelo cargado, para las pruebas y las capturas.
func model() -> Node3D:
	return _model


## Animación actual, o vacía si el modelo no trae AnimationPlayer.
func current_animation() -> StringName:
	if _player == null:
		return &""
	return StringName(_player.current_animation)


func _darken_clothes() -> void:
	var clothes: MeshInstance3D = _model.find_child("clothes", true, false) as MeshInstance3D
	if clothes == null or clothes.mesh == null:
		return
	# Oscurece con el tinte del shader de tela en lugar de un material plano:
	# el chanca conserva el tejido y las franjas, y deja de verse como un saco.
	for surface: int in range(clothes.mesh.get_surface_count()):
		var material: Material = clothes.get_active_material(surface)
		if material is ShaderMaterial:
			var cloth: ShaderMaterial = (material as ShaderMaterial).duplicate() as ShaderMaterial
			cloth.set_shader_parameter("cloth_tint", DARK_CLOTH_TINT)
			cloth.set_shader_parameter("tint", DARK_CLOTH_TINT)
			clothes.set_surface_override_material(surface, cloth)
		elif material is BaseMaterial3D:
			var plain: BaseMaterial3D = (material as BaseMaterial3D).duplicate() as BaseMaterial3D
			plain.albedo_color = DARK_CLOTH_TINT
			clothes.set_surface_override_material(surface, plain)


func _process(_delta: float) -> void:
	if _porra_pivot == null or _skeleton == null or _hand_index < 0:
		return
	var hand: Transform3D = _skeleton.global_transform * _skeleton.get_bone_global_pose(_hand_index)
	_porra_pivot.global_position = hand.origin + Vector3(0.08, 0.0, -0.05)


func _build_porra() -> void:
	_skeleton = _model.find_child("Skeleton3D", true, false) as Skeleton3D
	if _skeleton == null:
		return
	_hand_index = _skeleton.find_bone("RightHand")
	if _hand_index < 0:
		return
	_porra_pivot = Node3D.new()
	_porra_pivot.name = "PorraPivot"
	_porra_pivot.top_level = true
	_porra_pivot.rotation_degrees = Vector3(-20.0, 0.0, -25.0)
	add_child(_porra_pivot)
	var wood: StandardMaterial3D = StandardMaterial3D.new()
	wood.albedo_color = Color(0.30, 0.22, 0.14, 1.0)
	wood.roughness = 0.9
	var stone: StandardMaterial3D = StandardMaterial3D.new()
	stone.albedo_color = Color(0.42, 0.40, 0.37, 1.0)
	stone.roughness = 0.95
	var handle: MeshInstance3D = MeshInstance3D.new()
	var handle_mesh: CylinderMesh = CylinderMesh.new()
	handle_mesh.top_radius = 0.025
	handle_mesh.bottom_radius = 0.032
	handle_mesh.height = 0.55
	handle_mesh.radial_segments = 8
	handle.mesh = handle_mesh
	handle.material_override = wood
	handle.position = Vector3(0.0, 0.28, 0.0)
	_porra_pivot.add_child(handle)
	var head: MeshInstance3D = MeshInstance3D.new()
	var head_mesh: SphereMesh = SphereMesh.new()
	head_mesh.radius = 0.09
	head_mesh.height = 0.18
	head_mesh.radial_segments = 8
	head_mesh.rings = 4
	head.mesh = head_mesh
	head.material_override = stone
	head.position = Vector3(0.0, 0.56, 0.0)
	_porra_pivot.add_child(head)
