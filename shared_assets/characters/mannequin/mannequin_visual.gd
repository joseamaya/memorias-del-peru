class_name MannequinVisual
extends Node3D
## Maniquí UAL1 para actores simples: enemigos, aliados y figuras de fondo.
##
## Carga el GLB compartido, lo tiñe y reproduce clips por nombre. No conoce la
## lógica del juego; los actores le piden `play` y `set_tint`. Los NPC del acto I
## usan el mismo GLB a través de `NpcActor`, que conserva su máquina de estados.

const MODEL_PATH: String = "res://shared_assets/characters/mannequin/ual1_standard.glb"

## Color del cuerpo; se aplica al cargar o al cambiarlo.
var tint: Color = Color(0.62, 0.48, 0.36, 1.0)

var _model: Node3D = null
var _player: AnimationPlayer = null
var _pending_clip: StringName = &"Idle"


func _ready() -> void:
	var packed: PackedScene = load(MODEL_PATH) as PackedScene
	if packed == null:
		return
	_model = packed.instantiate() as Node3D
	if _model == null:
		return
	add_child(_model)
	# UAL1 mira hacia +Z; los actores orientan su -Z hacia el objetivo.
	_model.rotation.y = PI
	_player = _model.find_child("AnimationPlayer", true, false) as AnimationPlayer
	_apply_tint()
	play(_pending_clip)


## Reproduce un clip del maniquí. Si aún no ha cargado, lo deja pendiente.
func play(clip: StringName, speed: float = 1.0) -> void:
	_pending_clip = clip
	if _player == null or not _player.has_animation(clip):
		return
	_player.speed_scale = speed
	_player.play(clip, 0.2)


## Nodo del modelo cargado, para las pruebas.
func model() -> Node3D:
	return _model


## Cambia el color del cuerpo.
func set_tint(color: Color) -> void:
	tint = color
	_apply_tint()


func _apply_tint() -> void:
	if _model == null:
		return
	var meshes: Array[Node] = _model.find_children("*", "MeshInstance3D", true, false)
	if _model is MeshInstance3D:
		meshes.append(_model)
	for node: Node in meshes:
		var mesh_instance: MeshInstance3D = node as MeshInstance3D
		if mesh_instance == null:
			continue
		var material: StandardMaterial3D = StandardMaterial3D.new()
		# Arcilla teñida: el maniquí es un prototipo, no un cuerpo desnudo.
		material.albedo_color = tint.lerp(Color(0.62, 0.60, 0.55, 1.0), 0.5)
		material.roughness = 1.0
		mesh_instance.material_override = material
