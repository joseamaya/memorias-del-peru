class_name CharacterModelVisual
extends Node3D
## Visual de un personaje Quaternius.
##
## Carga el GLB con un [ModelSlot], aplica los materiales del proyecto y
## reproduce su reposo. Puede oscurecer la ropa y añadir una porra para los
## chancas. No conoce la lógica: los puntos de interacción y la colisión viven
## fuera. El modelo mira hacia -Z, como el actor, así que no se gira.

## Tinte de la ropa oscura de los chancas; multiplica el tejido original.
const DARK_CLOTH_TINT: Color = Color(0.30, 0.26, 0.23, 1.0)
## Pieza que la multitud oculta: el tupu. Es un alfiler pequeño que no se lee a
## distancia; las cejas sí: sin ellas la cara parece vacía. Los nombres de
## malla cambian entre los cuerpos masculino y femenino; el material no.
const CROWD_HIDDEN_MATERIALS: Array[String] = ["pch_tupu"]

@export var model_path: String = ""
@export var idle_clip: StringName = &"idle"
@export var dark_clothes: bool = false
@export var porra: bool = false
## LOD de multitud: oculta cejas y tupu para ahorrar draw calls sin perder la
## cara ni el pelo.
@export var crowd: bool = false
## Altura visible a la que se ajusta el modelo. Los GLB del elenco venían con
## alturas de 1,34 a 1,68 m; el jugador mide 1,70 y la diferencia se notaba.
## Con 0 no se escala: solo se apoyan los pies en el suelo.
@export var target_height: float = 1.58
## Variación de altura, para que la multitud no sea un molde.
@export var height_variation: float = 0.04

var _slot: ModelSlot = null
var _model: Node3D = null
var _player: AnimationPlayer = null
var _porra_pivot: Node3D = null
var _skeleton: Skeleton3D = null
var _hand_index: int = -1
var _head_index: int = -1
var _flashing: bool = false
var _flash_restore: Dictionary[MeshInstance3D, Material] = {}


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
	_fit_model()
	# Bajo el driver Dummy de las pruebas sin pantalla, los overrides de
	# material se liberan mal; en el juego y en las capturas sí se aplican.
	if DisplayServer.get_name() != "headless":
		SurfaceMaterials.apply_to_model(_model)
	_skeleton = _model.find_child("Skeleton3D", true, false) as Skeleton3D
	if _skeleton != null:
		_head_index = _skeleton.find_bone("Head")
	_player = QuaterniusClips.player_for(
		_model, _model.find_child("AnimationPlayer", true, false) as AnimationPlayer)
	if _player != null and _player.has_animation(idle_clip):
		_player.play(idle_clip)
	if dark_clothes:
		_darken_clothes()
	if porra:
		_build_porra()
	QuaterniusMaterials.apply_shadow_policy(_model)
	if crowd:
		_apply_crowd_lod()


## Ajusta la altura del modelo y apoya sus pies en el suelo.
func _fit_model() -> void:
	if target_height <= 0.0:
		ModelSlot.fit_height(_model, 0.0)
		return
	var jitter: float = float(absi(hash(name)) % 1000) / 1000.0 * 2.0 - 1.0
	ModelSlot.fit_height(_model, target_height + jitter * height_variation)


## Reproduce un clip. Acepta los nombres lógicos (`Walk`, `Idle`) y los
## propios (`attack`, `hit`); si el clip pedido no existe, cae a un equivalente.
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
			_:
				mapped = &"idle"
	if not _player.has_animation(mapped):
		return
	_player.play(mapped, 0.15, speed)


## LOD de multitud: las piezas pequeñas no se leen a distancia y cuestan un
## draw call cada una. La cara conserva ojos y pelo.
func _apply_crowd_lod() -> void:
	if _model == null:
		return
	for node: Node in _model.find_children("*", "MeshInstance3D", true, false):
		var mesh_instance: MeshInstance3D = node as MeshInstance3D
		if mesh_instance != null and QuaterniusMaterials.uses_material(
			mesh_instance, CROWD_HIDDEN_MATERIALS
		):
			mesh_instance.visible = false


## Punto de la cara para encuadrar un diálogo, tomado del hueso de la cabeza.
func focus_point() -> Vector3:
	if _skeleton != null and _head_index >= 0 and _skeleton.is_inside_tree():
		var head_pose: Transform3D = _skeleton.global_transform * _skeleton.get_bone_global_pose(_head_index)
		return head_pose.origin + Vector3.UP * 0.12
	return global_position + Vector3.UP * 1.55


## Nodo del modelo cargado, para las pruebas y las capturas.
func model() -> Node3D:
	return _model


## Pivote de la porra, o null si el personaje no la lleva. Lo usan las pruebas
## para comprobar que sigue la mano.
func porra_pivot() -> Node3D:
	return _porra_pivot


## Velocidad de desplazamiento de cada ciclo a velocidad 1 (m/s). Los clips Q
## traen su propia zancada; si se reproducen a 1.0 mientras el cuerpo va a otra
## velocidad, los pies patinan.
const WALK_CYCLE_SPEED: float = 1.2
const RUN_CYCLE_SPEED: float = 3.0


## Reproduce el ciclo de locomoción que corresponde a [param speed] (m/s) y lo
## ajusta para que la zancada acompañe al desplazamiento real.
func play_locomotion(speed: float) -> void:
	if speed >= 2.0:
		play(&"Run", speed / RUN_CYCLE_SPEED)
	else:
		play(&"Walk", speed / WALK_CYCLE_SPEED)


## Duración de un clip, o 0 si el personaje no lo tiene.
func clip_length(clip: StringName) -> float:
	if _player == null or not _player.has_animation(clip):
		return 0.0
	return _player.get_animation(clip).length


## Animación actual, o vacía si el modelo no trae AnimationPlayer.
func current_animation() -> StringName:
	if _player == null:
		return &""
	return StringName(_player.current_animation)


func _darken_clothes() -> void:
	var clothes: MeshInstance3D = null
	for node: Node in _model.find_children("*", "MeshInstance3D", true, false):
		var mesh_instance: MeshInstance3D = node as MeshInstance3D
		if mesh_instance == null or mesh_instance.mesh == null:
			continue
		if mesh_instance.name.to_lower().contains("cloth"):
			clothes = mesh_instance
			break
		for surface: int in range(mesh_instance.mesh.get_surface_count()):
			var candidate: Material = mesh_instance.get_active_material(surface)
			if candidate != null and candidate.resource_name.begins_with("pch_cloth"):
				clothes = mesh_instance
				break
		if clothes != null:
			break
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


## Destello breve al recibir un golpe. Se aplica a todas las mallas del modelo
## y se restaura el override anterior; si ya había un destello, no se apila.
func flash_hit(color: Color = Color(1.0, 0.96, 0.90, 1.0), seconds: float = 0.08) -> void:
	# Bajo el driver Dummy de las pruebas sin pantalla, los overrides de
	# material se liberan mal; en el juego y en las capturas sí se aplican.
	if DisplayServer.get_name() == "headless":
		return
	if _model == null or _flashing:
		return
	var meshes: Array[Node] = _model.find_children("*", "MeshInstance3D", true, false)
	if meshes.is_empty():
		return
	_flashing = true
	var material: StandardMaterial3D = StandardMaterial3D.new()
	material.albedo_color = color
	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	_flash_restore.clear()
	for node: Node in meshes:
		var mesh: MeshInstance3D = node as MeshInstance3D
		if mesh == null:
			continue
		_flash_restore[mesh] = mesh.material_override
		mesh.material_override = material
	await get_tree().create_timer(seconds, false).timeout
	if is_inside_tree():
		for mesh: MeshInstance3D in _flash_restore:
			if is_instance_valid(mesh):
				mesh.material_override = _flash_restore[mesh]
	_flash_restore.clear()
	_flashing = false


func _process(_delta: float) -> void:
	if _porra_pivot == null or _skeleton == null or _hand_index < 0:
		return
	# La porra sigue el transform completo de la mano, no solo su posición: si
	# solo siguiera el origen, se quedaría vertical mientras el brazo gira y el
	# golpe no se leería. El eje Y del hueso va del puño a los dedos, así que la
	# porra sale de la mano a lo largo de ese eje.
	var hand: Transform3D = _skeleton.global_transform * _skeleton.get_bone_global_pose(_hand_index)
	var grip: Basis = hand.basis.orthonormalized()
	_porra_pivot.global_transform = Transform3D(grip, hand.origin + grip.y * 0.04)


func _build_porra() -> void:
	_skeleton = _model.find_child("Skeleton3D", true, false) as Skeleton3D
	if _skeleton == null:
		return
	_hand_index = _skeleton.find_bone("RightHand")
	if _hand_index < 0:
		_hand_index = _skeleton.find_bone("hand_r")
	if _hand_index < 0:
		return
	_porra_pivot = Node3D.new()
	_porra_pivot.name = "PorraPivot"
	_porra_pivot.top_level = true
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
	handle.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
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
	head.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	_porra_pivot.add_child(head)
