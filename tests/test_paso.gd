extends RefCounted
## Comprueba el acto II en gris: escena, emboscada, honda, escudo y huida
## (Fase 7).

const PASO_PATH: String = "res://campaigns/01_pachacutec/scenes/world/paso.tscn"


func _spawn() -> Node:
	var tree: SceneTree = Engine.get_main_loop() as SceneTree
	if tree == null:
		return null
	var packed: PackedScene = load(PASO_PATH) as PackedScene
	if packed == null:
		return null
	var paso: Node = packed.instantiate()
	tree.root.add_child(paso)
	return paso


func test_paso_scene_starts() -> bool:
	var paso: Node = _spawn()
	if paso == null:
		return false
	var player: PlayerFPS = paso.get_node_or_null("PlayerFPS") as PlayerFPS
	var hud: PlayerHud = paso.get_node_or_null("UILayer/HUD") as PlayerHud
	var trigger: Area3D = paso.get_node_or_null("AmbushTrigger") as Area3D
	var ok: bool = player != null and hud != null and trigger != null
	ok = ok and paso.call("alive_enemies") == 4
	ok = ok and paso.call("is_ambush_active") != true
	ok = ok and paso.get_node_or_null("Ambusher1") is AmbushEnemy
	paso.free()
	return ok


func test_paso_ambush_and_combat() -> bool:
	var paso: Node = _spawn()
	if paso == null:
		return false
	var player: PlayerFPS = paso.get_node_or_null("PlayerFPS") as PlayerFPS
	var hud: PlayerHud = paso.get_node_or_null("UILayer/HUD") as PlayerHud
	var enemy: AmbushEnemy = paso.get_node_or_null("Ambusher1") as AmbushEnemy
	var character: CharacterState = paso.get_node_or_null("PlayerFPS/CharacterState") as CharacterState
	if player == null or hud == null or enemy == null or character == null:
		paso.free()
		return false
	paso.call("_start_ambush")
	var ok: bool = paso.call("is_ambush_active") == true
	# La honda ejecuta el ataque y consume aliento. El impacto del rayo se
	# comprueba en la escena; aquí se prueba el daño directo, porque la física
	# no ha registrado los cuerpos nuevos en el mismo fotograma.
	var combatant: Combatant = paso.get_node_or_null("PlayerFPS/PlayerCombatant") as Combatant
	var stamina_before: float = player.stamina.get_current()
	var before: float = enemy.character.get_health()
	paso.call("_attack")
	ok = ok and combatant != null and combatant.state == Combatant.State.ATTACKING
	ok = ok and player.stamina.get_current() < stamina_before
	enemy.take_hit(17.6)
	ok = ok and enemy.character.get_health() < before
	# El escudo reduce el daño.
	var health_before: float = character.get_health()
	paso.call("apply_player_damage", 20.0)
	ok = ok and is_equal_approx(character.get_health(), health_before - 20.0)
	paso.set("_blocking", true)
	health_before = character.get_health()
	paso.call("apply_player_damage", 20.0)
	ok = ok and is_equal_approx(character.get_health(), health_before - 6.0)
	# El enemigo ataca si está en alcance.
	paso.set("_blocking", false)
	player.global_position = enemy.global_position + Vector3(0.0, 0.0, 5.0)
	var health_before_enemy: float = character.get_health()
	enemy.brain.advance(1.0)
	enemy._physics_process(1.0)
	ok = ok and character.get_health() < health_before_enemy
	# Un enemigo con la moral baja huye y deja de contar.
	var second: AmbushEnemy = paso.get_node_or_null("Ambusher2") as AmbushEnemy
	if second != null:
		second.take_hit(10.0)
		second.brain.character.change_morale(-80.0)
		second.brain.think(0.0, 5.0, true)
		ok = ok and second.is_resolved()
	# Al resolverse todos se abre la decisión del herido y el maíz.
	var state: CampaignStateService = (Engine.get_main_loop() as SceneTree).root.get_node_or_null("CampaignState") as CampaignStateService
	if state != null:
		state.clear()
	for index: int in range(1, 5):
		var each: AmbushEnemy = paso.get_node_or_null("Ambusher%d" % index) as AmbushEnemy
		if each != null:
			each.take_hit(200.0)
	paso.call("_physics_process", 0.1)
	ok = ok and hud.is_dialogue_open()
	hud.get_dialogue_panel().choice_selected.emit(0)
	paso.call("_on_dialogue_advanced")
	hud.get_dialogue_panel().choice_selected.emit(0)
	paso.call("_on_dialogue_advanced")
	ok = ok and paso.call("is_completed") == true
	if state != null:
		ok = ok and state.get_flag(&"herido_salvado") == 1
		ok = ok and state.get_flag(&"maiz_guardado") == 1
		state.clear()
	paso.free()
	return ok


func test_paso_camp_rest() -> bool:
	var paso: Node = _spawn()
	if paso == null:
		return false
	var player: PlayerFPS = paso.get_node_or_null("PlayerFPS") as PlayerFPS
	var hud: PlayerHud = paso.get_node_or_null("UILayer/HUD") as PlayerHud
	var camp: CampPoint = paso.get_node_or_null("CampPoint") as CampPoint
	var state: CampaignStateService = (Engine.get_main_loop() as SceneTree).root.get_node_or_null("CampaignState") as CampaignStateService
	if player == null or hud == null or camp == null or state == null:
		paso.free()
		return false
	state.clear()
	camp.interact(player)
	var ok: bool = hud.is_dialogue_open()
	ok = ok and hud.get_dialogue_panel().get_choice_count() == 4
	hud.get_dialogue_panel().choice_selected.emit(0)
	paso.call("_on_dialogue_advanced")
	ok = ok and state.get_flag(&"descanso") == 1
	ok = ok and not hud.is_dialogue_open()
	ok = ok and player.process_mode == Node.PROCESS_MODE_INHERIT
	state.clear()
	paso.free()
	return ok
