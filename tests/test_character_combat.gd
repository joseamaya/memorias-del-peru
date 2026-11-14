extends RefCounted
## Los clips de combate (`attack` y `hit`) llegan a todos los personajes desde
## `pch_npc_combat.glb`, un GLB con la misma armadura y sin mallas. Comprueba
## que se cargan, que las rutas de pista apuntan al esqueleto del personaje y
## que el reproductor los acepta.

const MODEL_PATH: String = "res://campaigns/01_pachacutec/assets/models/pch_npc_commoner.glb"
const COMBAT_PATH: String = "res://campaigns/01_pachacutec/assets/animation/pch_npc_combat.glb"


func _spawn_visual() -> CharacterModelVisual:
	var tree: SceneTree = Engine.get_main_loop() as SceneTree
	if tree == null:
		return null
	var visual: CharacterModelVisual = CharacterModelVisual.new()
	visual.model_path = MODEL_PATH
	visual.porra = true
	tree.root.add_child(visual)
	return visual


func test_combat_library_exists() -> bool:
	var ok: bool = ResourceLoader.exists(COMBAT_PATH)
	var packed: PackedScene = load(COMBAT_PATH) as PackedScene
	if packed == null:
		return false
	var holder: Node = packed.instantiate()
	var player: AnimationPlayer = holder.find_child("AnimationPlayer", true, false) as AnimationPlayer
	ok = ok and player != null
	if player != null:
		ok = ok and player.has_animation(&"attack") and player.has_animation(&"hit")
		# El GLB de combate solo lleva la armadura: sin mallas no duplica el
		# personaje ni sus texturas.
		ok = ok and holder.find_children("*", "MeshInstance3D", true, false).is_empty()
		var attack: Animation = player.get_animation(&"attack")
		var hit: Animation = player.get_animation(&"hit")
		ok = ok and attack.get_track_count() > 8 and hit.get_track_count() > 8
		ok = ok and attack.length > 0.9 and hit.length > 0.5
		# Las pistas apuntan al esqueleto con el mismo nombre que el personaje.
		var path: String = str(attack.track_get_path(0))
		ok = ok and path.begins_with("Human_rig/Skeleton3D:")
	holder.free()
	return ok


func test_combat_clips_play_on_character() -> bool:
	var visual: CharacterModelVisual = _spawn_visual()
	if visual == null:
		return false
	var player: AnimationPlayer = visual.model().find_child("AnimationPlayer", true, false) as AnimationPlayer
	var ok: bool = player != null
	if player != null:
		ok = ok and player.has_animation(&"attack") and player.has_animation(&"hit")
		visual.play(&"attack")
		ok = ok and visual.current_animation() == &"attack"
		visual.play(&"hit")
		ok = ok and visual.current_animation() == &"hit"
		visual.play(&"Idle")
		ok = ok and visual.current_animation() == &"idle"
		# La porra cuelga de la mano y sigue su giro, no solo su posición.
		ok = ok and visual.porra_pivot() != null
		ok = ok and visual.porra_pivot().top_level
	visual.queue_free()
	return ok
