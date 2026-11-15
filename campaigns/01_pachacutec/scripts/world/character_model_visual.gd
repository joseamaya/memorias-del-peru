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
## Clips de combate compartidos por todo el elenco. Viven en un GLB aparte para
## no duplicar mallas: solo trae la armadura y las dos acciones.
const COMBAT_LIBRARY_PATH: String = "res://campaigns/01_pachacutec/assets/animation/pch_npc_combat.glb"
const COMBAT_CLIPS: Array[StringName] = [&"attack", &"hit", &"death"]

## Copias de los clips de combate, cargadas una vez para todos los personajes.
static var _combat_cache: Dictionary[StringName, Animation] = {}

@export var model_path: String = ""
@export var idle_clip: StringName = &"idle"
@export var dark_clothes: bool = false
@export var porra: bool = false
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
	_player = _model.find_child("AnimationPlayer", true, false) as AnimationPlayer
	if _player != null:
		_add_combat_clips()
	if _player != null and _player.has_animation(idle_clip):
		_player.play(idle_clip)
	if dark_clothes:
		_darken_clothes()
	if porra:
		_build_porra()


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


## Añade `attack` y `hit` a la librería del personaje. La armadura del GLB de
## combate es la misma, así que las rutas de pista coinciden.
func _add_combat_clips() -> void:
	var library: AnimationLibrary = _player.get_animation_library(&"")
	if library == null:
		return
	for clip: StringName in _load_combat_clips():
		if not library.has_animation(clip):
			var copy: Animation = _combat_cache[clip].duplicate() as Animation
			library.add_animation(clip, copy)


## Carga los clips de combate una sola vez y devuelve los nombres disponibles.
static func _load_combat_clips() -> Array[StringName]:
	var names: Array[StringName] = []
	if _combat_cache.is_empty():
		if ResourceLoader.exists(COMBAT_LIBRARY_PATH):
			var packed: PackedScene = load(COMBAT_LIBRARY_PATH) as PackedScene
			if packed != null:
				var holder: Node = packed.instantiate()
				var player: AnimationPlayer = holder.find_child(
					"AnimationPlayer", true, false) as AnimationPlayer
				if player != null:
					for clip: StringName in COMBAT_CLIPS:
						if player.has_animation(clip):
							# Se copia antes de liberar el nodo: la librería
							# muere con él.
							var copy: Animation = player.get_animation(clip).duplicate() as Animation
							_combat_cache[clip] = copy
				holder.free()
	for clip: StringName in _combat_cache:
		names.append(clip)
	return names


## Nodo del modelo cargado, para las pruebas y las capturas.
func model() -> Node3D:
	return _model


## Pivote de la porra, o null si el personaje no la lleva. Lo usan las pruebas
## para comprobar que sigue la mano.
func porra_pivot() -> Node3D:
	return _porra_pivot


## Velocidad de desplazamiento de cada ciclo a velocidad 1 (m/s). Los clips del
## elenco vienen de la captura de CMU y traen su propia zancada; si se reproducen
## a 1.0 mientras el cuerpo va a otra velocidad, los pies patinan.
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
