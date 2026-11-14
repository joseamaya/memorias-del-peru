extends RefCounted
## Comprueba la vida de la llacta (punto 4 del plan de realismo): el viento
## mece el ichu y la queñua con ráfagas que varían, los personajes tienen voz
## para sus pasos y los trabajos de la tejedora y el agricultor marcan su golpe.

const WORLD_PATH: String = "res://campaigns/01_pachacutec/scenes/world/mundo_base.tscn"
const LOOM_SOUND: String = "res://shared_assets/audio/telar_golpe.wav"
const AUDIO_LICENSE: String = "res://shared_assets/audio/LICENSE.md"


func test_wind_moves_vegetation() -> bool:
	var tree: SceneTree = Engine.get_main_loop() as SceneTree
	if tree == null:
		return false
	var world: Node = (load(WORLD_PATH) as PackedScene).instantiate()
	tree.root.add_child(world)
	var wind: LlactaWind = world.get_node_or_null("Wind") as LlactaWind
	var ok: bool = wind != null and wind.materials.size() == 2
	if not ok:
		world.free()
		return false
	for material: ShaderMaterial in wind.materials:
		var bend: Variant = material.get_shader_parameter("wind_bend")
		var bend_value: float = 0.0
		if bend is float:
			bend_value = bend
		ok = ok and bend_value > 0.0
	var ichu: MultiMeshInstance3D = world.find_child("IchuChunk_*", true, false) as MultiMeshInstance3D
	ok = ok and ichu != null and wind.materials.has(ichu.material_override as ShaderMaterial)
	# En dos minutos hay calma y ráfaga, y el material recibe el valor.
	var lowest: float = 1.0
	var highest: float = 0.0
	for i: int in range(240):
		wind.advance(0.5)
		lowest = minf(lowest, wind.gust)
		highest = maxf(highest, wind.gust)
	ok = ok and lowest < 0.2 and highest > 0.6 and lowest >= 0.0 and highest <= 1.0
	var applied: Variant = wind.materials[0].get_shader_parameter("wind_gust")
	var applied_value: float = -1.0
	if applied is float:
		applied_value = applied
	ok = ok and is_equal_approx(applied_value, wind.gust)
	world.free()
	return ok


func test_npc_steps_and_work_beats() -> bool:
	var tree: SceneTree = Engine.get_main_loop() as SceneTree
	if tree == null:
		return false
	var world: Node = (load(WORLD_PATH) as PackedScene).instantiate()
	tree.root.add_child(world)
	var weaver: NpcActor = world.get_node("Llacta/NPCs/Tejedora") as NpcActor
	var farmer: NpcActor = world.get_node("Llacta/NPCs/Agricultor") as NpcActor
	# El golpe del telar llega una vez por ciclo de la animación de tejer.
	var beats: Array[int] = [0, 0]
	weaver.beat.connect(func(_animation: StringName) -> void: beats[0] += 1)
	farmer.beat.connect(func(_animation: StringName) -> void: beats[1] += 1)
	weaver.animation_player().advance(0.05)
	farmer.animation_player().advance(0.05)
	for i: int in range(120):
		weaver.animation_player().advance(0.05)
		weaver._process(0.05)
		farmer.animation_player().advance(0.05)
		farmer._process(0.05)
	# El ciclo del maniquí es más largo que el de los modelos propios: en 6 s
	# llega al menos un golpe de cada oficio.
	var ok: bool = beats[0] >= 1 and beats[0] <= 8 and beats[1] >= 1 and beats[1] <= 8
	# Los pasos salen del propio personaje.
	var streams: Array[AudioStream] = [load("res://shared_assets/audio/pasos_tierra_01.wav") as AudioStream]
	weaver.set_footsteps(streams)
	var steps: AudioStreamPlayer3D = weaver.get_node_or_null("Steps") as AudioStreamPlayer3D
	ok = ok and steps != null and steps.bus == &"SFX"
	# El golpe del telar es una pieza propia registrada en la licencia.
	ok = ok and load(LOOM_SOUND) is AudioStreamWAV
	ok = ok and FileAccess.get_file_as_string(AUDIO_LICENSE).contains("telar_golpe.wav")
	world.free()
	return ok
