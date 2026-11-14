class_name RealisticCharacterVisual
extends Node3D
## Visual con modelo propio para los actores de los actos II y III.
##
## Carga un GLB de personaje del proyecto, reproduce sus clips de reposo,
## caminar y conversación, tiñe la ropa y añade una porra simple a los
## exploradores chancas. Los clips de ataque y golpe no existen en estos
## modelos: se resuelven con una embestida y un destello, para que el combate
## siga teniendo respuesta visual sin inventar animaciones.

const MODEL_DIR: String = "res://campaigns/01_pachacutec/assets/models/"
const DEFAULT_MODEL: String = "pch_npc_commoner.glb"
## Nombres lógicos del juego → clips de los modelos propios.
const CLIPS: Dictionary[StringName, StringName] = {
	&"Idle": &"idle",
	&"Walk": &"walk",
	&"Run": &"run",
	&"Talk": &"talk",
	&"Tired": &"tired",
}
const CLOTH_MATERIAL: StringName = &"pch_cloth"

## Archivo del modelo; se fija antes de añadirlo al árbol.
var model_file: String = DEFAULT_MODEL
## Tinte de la ropa (multiplica la textura del textil).
var tint: Color = Color(1.0, 1.0, 1.0, 1.0)
## Añade una porra a la altura de la mano derecha.
var with_porra: bool = false

var _model: Node3D = null
var _player: AnimationPlayer = null
var _clothes: StandardMaterial3D = null
var _porra: Node3D = null
var _current_clip: StringName = &""
var _motion_tween: Tween = null
var _flash_tween: Tween = null


func _ready() -> void:
	var packed: PackedScene = load(MODEL_DIR + model_file) as PackedScene
	if packed == null:
		return
	_model = packed.instantiate() as Node3D
	if _model == null:
		return
	add_child(_model)
	_player = _model.find_child("AnimationPlayer", true, false) as AnimationPlayer
	_apply_tint()
	if with_porra:
		_add_porra()
	play(&"Idle")


## Reproduce un clip lógico. Los de combate se resuelven con gesto procedural.
func play(clip: StringName, speed: float = 1.0) -> void:
	if _player == null:
		return
	var mapped: StringName = CLIPS.get(clip, &"")
	if mapped == &"":
		if clip == &"Sword_Attack":
			_swing()
		elif clip == &"Hit_Chest":
			_flash()
		return
	if not _player.has_animation(mapped):
		return
	_current_clip = clip
	_player.speed_scale = speed
	_player.play(mapped, 0.2)


## Cambia el tinte de la ropa; se aplica al cargar o al cambiarlo.
func set_tint(color: Color) -> void:
	tint = color
	_apply_tint()


## Nodo del modelo, para las pruebas.
func model() -> Node3D:
	return _model


## Indica si el modelo cargó con su reproductor de animaciones.
func is_animated() -> bool:
	return _player != null


func _apply_tint() -> void:
	if _model == null:
		return
	for node: Node in _model.find_children("*", "MeshInstance3D", true, false):
		var mesh_instance: MeshInstance3D = node as MeshInstance3D
		if mesh_instance.mesh == null:
			continue
		for surface: int in range(mesh_instance.mesh.get_surface_count()):
			var material: StandardMaterial3D = mesh_instance.mesh.surface_get_material(surface) as StandardMaterial3D
			if material == null or material.resource_name != CLOTH_MATERIAL:
				continue
			if _clothes == null:
				_clothes = material.duplicate() as StandardMaterial3D
			_clothes.albedo_color = tint
			mesh_instance.set_surface_override_material(surface, _clothes)


## Porra de madera con cabeza de piedra, colgada de un pivote que gira al
## atacar. No usa huesos: la mano del modelo no está expuesta por nombre.
func _add_porra() -> void:
	_porra = Node3D.new()
	_porra.name = "Porra"
	_porra.position = Vector3(0.3, 0.98, -0.12)
	add_child(_porra)
	var wood: StandardMaterial3D = StandardMaterial3D.new()
	wood.albedo_color = Color(0.33, 0.24, 0.16, 1.0)
	wood.roughness = 1.0
	var stone: StandardMaterial3D = StandardMaterial3D.new()
	stone.albedo_color = Color(0.42, 0.40, 0.37, 1.0)
	stone.roughness = 1.0
	var handle: MeshInstance3D = MeshInstance3D.new()
	var cylinder: CylinderMesh = CylinderMesh.new()
	cylinder.top_radius = 0.03
	cylinder.bottom_radius = 0.04
	cylinder.height = 0.62
	handle.mesh = cylinder
	handle.material_override = wood
	handle.position = Vector3(0.0, -0.3, 0.0)
	_porra.add_child(handle)
	var head: MeshInstance3D = MeshInstance3D.new()
	var sphere: SphereMesh = SphereMesh.new()
	sphere.radius = 0.11
	sphere.height = 0.22
	sphere.radial_segments = 8
	sphere.rings = 4
	head.mesh = sphere
	head.material_override = stone
	head.position = Vector3(0.0, -0.66, 0.0)
	_porra.add_child(head)


## Embiste hacia delante y descarga la porra; vuelve al sitio.
func _swing() -> void:
	if _model == null:
		return
	if _motion_tween != null and _motion_tween.is_valid():
		_motion_tween.kill()
	_motion_tween = create_tween()
	_motion_tween.set_parallel(true)
	_motion_tween.tween_property(_model, "position:z", -0.28, 0.09)
	if _porra != null:
		_motion_tween.tween_property(_porra, "rotation:x", -1.25, 0.09)
	_motion_tween.set_parallel(false)
	_motion_tween.tween_property(_model, "position:z", 0.0, 0.18)
	if _porra != null:
		_motion_tween.parallel().tween_property(_porra, "rotation:x", 0.0, 0.18)


## Destello rojizo en la ropa al recibir un golpe.
func _flash() -> void:
	if _clothes == null:
		return
	if _flash_tween != null and _flash_tween.is_valid():
		_flash_tween.kill()
	_flash_tween = create_tween()
	_flash_tween.tween_property(_clothes, "albedo_color", Color(0.85, 0.22, 0.18, 1.0), 0.06)
	_flash_tween.tween_property(_clothes, "albedo_color", tint, 0.18)
