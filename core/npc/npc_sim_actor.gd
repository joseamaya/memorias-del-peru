class_name NpcSimActor
extends Node3D
## Representación viva de un NPC dentro de un sector.
##
## El actor solo existe mientras el director lo considera activo. El LOD decide
## si se mueve y si reproduce animación; la animación real llegará con los
## personajes de F2, aquí es un balanceo de malla que sí cuesta CPU/GPU.

enum Lod {
	DORMANT,
	SIMULATED,
	ANIMATED,
}

var id: StringName = &""
var definition: NpcDefinition = null
var mover: NpcMover = null

var _lod: int = Lod.DORMANT
var _body: MeshInstance3D = null
var _animation: AnimationPlayer = null


## Construye cuerpo y animación de marcador. El nodo queda dormido.
##
## Si la definición trae `dialogue_id`, añade un punto de conversación con su
## colisionador: solo los NPC con nombre y diálogo se pueden hablar.
func setup(npc_definition: NpcDefinition, npc_mover: NpcMover) -> void:
	definition = npc_definition
	mover = npc_mover
	if definition != null:
		id = definition.id
		name = String(id)
	_build_body()
	if definition != null and definition.dialogue_id != &"":
		_build_talk()
	set_lod(Lod.DORMANT)


func set_lod(level: int) -> void:
	if _lod == level:
		return
	_lod = level
	if _body != null:
		_body.visible = level != Lod.DORMANT
	if _animation != null:
		if level == Lod.ANIMATED:
			_animation.play(&"idle")
		else:
			_animation.stop()


func get_lod() -> int:
	return _lod


func is_animated() -> bool:
	return _lod == Lod.ANIMATED


## Punto al que mira el jugador al hablar. El actor vive en el centro del
## cuerpo (0,9 m sobre el suelo), no en los pies: sin esto el encuadre apuntaba
## 0,75 m por encima de la cabeza.
func focus_point() -> Vector3:
	return global_position + Vector3.UP * 0.7


func advance(delta: float) -> void:
	if mover != null:
		mover.advance(self, delta)


func _build_body() -> void:
	var capsule: CapsuleMesh = CapsuleMesh.new()
	capsule.radius = 0.35
	capsule.height = 1.7
	var material: StandardMaterial3D = StandardMaterial3D.new()
	material.albedo_color = _tier_color()
	capsule.material = material
	_body = MeshInstance3D.new()
	_body.name = "Body"
	_body.mesh = capsule
	add_child(_body)
	_animation = AnimationPlayer.new()
	_animation.name = "Animation"
	var animation: Animation = Animation.new()
	var track: int = animation.add_track(Animation.TYPE_VALUE)
	animation.track_set_path(track, NodePath("Body:position"))
	animation.track_insert_key(track, 0.0, Vector3.ZERO)
	animation.track_insert_key(track, 0.5, Vector3(0.0, 0.05, 0.0))
	animation.track_insert_key(track, 1.0, Vector3.ZERO)
	animation.length = 1.0
	animation.loop_mode = Animation.LOOP_LINEAR
	var library: AnimationLibrary = AnimationLibrary.new()
	library.add_animation(&"idle", animation)
	_animation.add_animation_library(&"", library)
	add_child(_animation)


func _build_talk() -> void:
	var talk: NpcInteractable = NpcInteractable.new()
	talk.name = "Talk"
	talk.setup(definition)
	talk.highlight_target = _body
	add_child(talk)


func _tier_color() -> Color:
	if definition == null:
		return Color(0.6, 0.6, 0.6)
	match definition.tier:
		NpcDefinition.Tier.NARRATIVE:
			return Color(0.85, 0.72, 0.40)
		NpcDefinition.Tier.AMBIENT:
			return Color(0.55, 0.58, 0.60)
		_:
			return Color(0.62, 0.45, 0.30)
