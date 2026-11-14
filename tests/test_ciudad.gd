extends RefCounted
## Comprueba el acto III en gris: reclutamiento según las banderas del acto II,
## Cusi Yupanqui, defensa y epílogo (Fase 7).

const CIUDAD_PATH: String = "res://campaigns/01_pachacutec/scenes/world/ciudad.tscn"


func _spawn() -> Node:
	var tree: SceneTree = Engine.get_main_loop() as SceneTree
	if tree == null:
		return null
	var packed: PackedScene = load(CIUDAD_PATH) as PackedScene
	if packed == null:
		return null
	var ciudad: Node = packed.instantiate()
	tree.root.add_child(ciudad)
	return ciudad


func _state() -> CampaignStateService:
	var tree: SceneTree = Engine.get_main_loop() as SceneTree
	if tree == null:
		return null
	return tree.root.get_node_or_null("CampaignState") as CampaignStateService


func test_ciudad_scene_starts() -> bool:
	var ciudad: Node = _spawn()
	if ciudad == null:
		return false
	var hud: PlayerHud = ciudad.get_node_or_null("UILayer/HUD") as PlayerHud
	var player: PlayerFPS = ciudad.get_node_or_null("PlayerFPS") as PlayerFPS
	var ok: bool = hud != null and player != null
	ok = ok and ciudad.get_node_or_null("Recruit0") != null
	ok = ok and ciudad.get_node_or_null("Recruit1") != null
	ok = ok and ciudad.get_node_or_null("Recruit2") != null
	ok = ok and ciudad.get_node_or_null("CusiPoint") != null
	ok = ok and ciudad.call("ally_count") == 0
	# Reclutas, Cusi y el viejo de la víspera usan los modelos propios.
	var visuals: int = 0
	for child: Node in ciudad.get_children():
		if child is CharacterModelVisual:
			visuals += 1
			var model: Node3D = (child as CharacterModelVisual).model()
			ok = ok and model != null
	ok = ok and visuals == 5
	ciudad.free()
	return ok


## La ciudad de 1438 tiene terreno, santuario, catorce casas con modelo,
## muro de pirca, terrazas y una multitud vestida que no interactúa.
func test_ciudad_art() -> bool:
	var ciudad: Node = _spawn()
	if ciudad == null:
		return false
	var terrain: MeshInstance3D = ciudad.get_node_or_null("Terrain/TerrainMesh") as MeshInstance3D
	var houses: Node = ciudad.get_node_or_null("Houses")
	var crowd: Node = ciudad.get_node_or_null("Crowd")
	var walls: Node = ciudad.get_node_or_null("Walls")
	var sanctuary: Node = ciudad.get_node_or_null("Sanctuary")
	var terraces: Node = ciudad.get_node_or_null("Terraces")
	var ok: bool = terrain != null and terrain.material_override is ShaderMaterial
	ok = ok and sanctuary != null and walls != null and terraces != null
	ok = ok and walls.get_node_or_null("WallMesh") != null
	ok = ok and houses != null and houses.get_child_count() == 14
	if houses != null:
		for house: Node in houses.get_children():
			var slot: ModelSlot = house.get_node_or_null("ModelSlot") as ModelSlot
			ok = ok and house.is_in_group("houses")
			ok = ok and slot != null and slot.model != null
	ok = ok and crowd != null and crowd.get_child_count() == 10
	if crowd != null:
		for figure: Node in crowd.get_children():
			var visual: MannequinVisual = figure as MannequinVisual
			ok = ok and visual != null
			if visual != null:
				var outfit: DressedMannequin = visual.get_node_or_null("Outfit") as DressedMannequin
				ok = ok and outfit != null and outfit.is_built()
	ok = ok and ciudad.get_node_or_null("Gate/Lintel") != null
	ok = ok and ciudad.get_node_or_null("WallCaps/NorthCap") != null
	ok = ok and ciudad.get_node_or_null("PlazaFurniture/Bench0") != null
	ok = ok and ciudad.get_node_or_null("SanctuaryProps/Altar") != null
	ok = ok and ciudad.get_node_or_null("Vegetation/Ichu0") != null
	ciudad.free()
	return ok


## Al empezar la defensa, la multitud deja la plaza, camina a su refugio y se
## detiene; su cuerpo de colisión usa la capa que solo consulta el jugador.
func test_ciudad_crowd_retreats() -> bool:
	var state: CampaignStateService = _state()
	if state == null:
		return false
	state.clear()
	var ciudad: Node = _spawn()
	if ciudad == null:
		state.clear()
		return false
	var crowd: Node = ciudad.get_node_or_null("Crowd")
	var first: MannequinVisual = null
	if crowd != null:
		first = crowd.get_child(0) as MannequinVisual
	if first == null:
		ciudad.free()
		state.clear()
		return false
	var ok: bool = true
	var body: StaticBody3D = first.get_node_or_null("CrowdBody") as StaticBody3D
	ok = ok and body != null and body.collision_layer == 16
	var start: Vector3 = first.global_position
	ciudad.call("_start_defense")
	ok = ok and ciudad.get("_crowd_retreating") == true
	ciudad.call("_process", 1.0)
	ok = ok and first.global_position.distance_to(start) > 0.5
	for _i: int in range(20):
		ciudad.call("_process", 1.0)
	ok = ok and ciudad.get("_crowd_retreating") == false
	ok = ok and ciudad.call("is_ambush_active") == true
	ciudad.free()
	state.clear()
	return ok


func test_ciudad_recruits_and_defense() -> bool:
	var state: CampaignStateService = _state()
	if state == null:
		return false
	state.clear()
	state.set_flag(&"maiz_guardado", 1)
	state.set_flag(&"herido_salvado", 1)
	state.set_flag(&"coca_compartida", 1)
	var ciudad: Node = _spawn()
	if ciudad == null:
		state.clear()
		return false
	var hud: PlayerHud = ciudad.get_node_or_null("UILayer/HUD") as PlayerHud
	var player: PlayerFPS = ciudad.get_node_or_null("PlayerFPS") as PlayerFPS
	if hud == null or player == null:
		ciudad.free()
		state.clear()
		return false
	var ok: bool = true
	for index: int in range(3):
		var point: CampPoint = ciudad.get_node_or_null("Recruit%d" % index) as CampPoint
		if point == null:
			ok = false
			break
		point.interact(player)
		ok = ok and hud.is_dialogue_open()
		hud.get_dialogue_panel().choice_selected.emit(0)
		ciudad.call("_on_dialogue_advanced")
		ok = ok and not hud.is_dialogue_open()
	ok = ok and ciudad.call("ally_count") == 3
	ok = ok and state.has_flag(&"aliado_0") and state.has_flag(&"aliado_2")
	var cusi: CampPoint = ciudad.get_node_or_null("CusiPoint") as CampPoint
	if cusi != null:
		cusi.interact(player)
		ok = ok and hud.is_dialogue_open()
		hud.get_dialogue_panel().choice_selected.emit(0)
		ciudad.call("_on_dialogue_advanced")
	ok = ok and ciudad.call("is_ambush_active") == true
	var enemy: AmbushEnemy = ciudad.get_node_or_null("Defender1") as AmbushEnemy
	if enemy != null:
		enemy.take_hit(200.0)
	ciudad.call("_physics_process", 0.1)
	ok = ok and ciudad.call("is_completed") == true
	ok = ok and hud.is_end_card_visible()
	ciudad.free()
	state.clear()
	return ok


func test_ciudad_vespera_is_belief() -> bool:
	var state: CampaignStateService = _state()
	if state == null:
		return false
	state.clear()
	var ciudad: Node = _spawn()
	if ciudad == null:
		return false
	var hud: PlayerHud = ciudad.get_node_or_null("UILayer/HUD") as PlayerHud
	var player: PlayerFPS = ciudad.get_node_or_null("PlayerFPS") as PlayerFPS
	var point: CampPoint = ciudad.get_node_or_null("VesperaPoint") as CampPoint
	var journal: Journal = ciudad.get_node_or_null("PlayerFPS/Journal") as Journal
	if hud == null or player == null or point == null or journal == null:
		ciudad.free()
		return false
	# La leyenda no altera aliados ni enemigos: es relato, no mecánica.
	var allies_before: Variant = ciudad.call("ally_count")
	point.interact(player)
	var ok: bool = hud.is_dialogue_open()
	hud.get_dialogue_panel().choice_selected.emit(0)
	ciudad.call("_on_dialogue_advanced")
	ok = ok and state.has_flag(&"mem_pururaucas")
	ok = ok and journal.has(&"mem_pururaucas")
	var entry: JournalEntry = journal.get_entry(&"mem_pururaucas")
	ok = ok and entry != null and entry.badge == &"N" and entry.source_key == &"PCH-031"
	ciudad.call("_on_dialogue_advanced")
	ok = ok and not hud.is_dialogue_open()
	ok = ok and ciudad.call("ally_count") == allies_before
	ok = ok and ciudad.call("alive_enemies") == 0
	# La «Memoria» se abre con J y conserva la leyenda.
	var open_event: InputEventAction = InputEventAction.new()
	open_event.action = &"journal"
	open_event.pressed = true
	ciudad.call("_unhandled_input", open_event)
	ok = ok and hud.is_journal_open()
	ciudad.call("_unhandled_input", open_event)
	ok = ok and not hud.is_journal_open()
	# Escuchar de nuevo no duplica la entrada ni abre el diálogo.
	point.interact(player)
	ok = ok and not hud.is_dialogue_open()
	ok = ok and journal.count() == 1
	ciudad.free()
	state.clear()
	return ok
