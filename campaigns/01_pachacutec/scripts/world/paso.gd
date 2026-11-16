class_name PasoWorld
extends Node3D
## Acto II: el paso de montaña y la emboscada chanca.
##
## Prueba el arco del acto II con geometría de bloqueo, sin arte final: sendero,
## roquedales, refugio y arroyo; cuatro exploradores con moral y huida; honda
## del jugador y escudo. No es la versión definitiva: es el arnés para probar
## distancia, cobertura y decisiones antes de invertir en arte.

const PASS_SIZE: float = 80.0
const TERRAIN_SIZE: float = 160.0
const TERRAIN_RESOLUTION: int = 64
const GRASS_COLOR: Color = Color(0.47, 0.46, 0.33, 1.0)
const ROCK_COLOR: Color = Color(0.45, 0.43, 0.41, 1.0)
const DIRT_COLOR: Color = Color(0.46, 0.38, 0.30, 1.0)
const WATER_COLOR: Color = Color(0.30, 0.46, 0.52, 0.68)
## El arroyo corre encajado en el lado oeste; el agua queda por debajo de la
## orilla para que no se derrame sobre el terreno.
const STREAM_X: float = -14.0
const WATER_LEVEL: float = -0.75
const ENEMY_POSITIONS: Array[Vector3] = [
	Vector3(5.0, 0.0, -2.0),
	Vector3(-5.0, 0.0, -4.0),
	Vector3(8.0, 0.0, -10.0),
	Vector3(-8.0, 0.0, -12.0),
]
const ROCK_POSITIONS: Array[Vector3] = [
	Vector3(7.0, 0.0, 6.0),
	Vector3(-7.0, 0.0, 4.0),
	Vector3(10.0, 0.0, -2.0),
	Vector3(-10.0, 0.0, -6.0),
	Vector3(6.0, 0.0, -14.0),
	Vector3(-6.0, 0.0, -16.0),
	Vector3(15.0, 0.0, -8.0),
	Vector3(-17.0, 0.0, 12.0),
]
const PLAYER_DAMAGE_BLOCKED: float = 0.3
const CAMP_SCENE: String = "res://campaigns/01_pachacutec/scenes/objects/camp_point.tscn"
const CAMP_POSITION: Vector3 = Vector3(-4.0, 0.9, 18.0)
const DISTRACT_POSITION: Vector3 = Vector3(12.0, 0.9, 6.0)
## El sigilo va por la orilla este del arroyo, no dentro del cauce.
const SNEAK_POSITION: Vector3 = Vector3(-10.0, 0.9, 6.0)
const BOUNDS_HALF_X: float = 32.0
const BOUNDS_HALF_Z: float = 39.0
const CLOUD_SHADER_PATH: String = "res://shared_assets/materials/nubes.gdshader"
const CLOUD_DOME_RADIUS: float = 420.0
const CLOUD_DOME_SEGMENTS: int = 48
const CLOUD_DOME_RINGS: int = 24

@onready var player: PlayerFPS = $PlayerFPS
@onready var hud: PlayerHud = $UILayer/HUD
@onready var hint_label: Label = $UILayer/HintLabel
@onready var spawn: Marker3D = $PlayerSpawn

var character: CharacterState = null
var player_combatant: Combatant = null
var inventory: Inventory = null
var journal: Journal = null
var dialogue: DialogueRunner = null

var _camp_graph: DialogueGraph = null
var _aftermath_graph: DialogueGraph = null
var _aftermath_pending: bool = false
var _camp_visuals: Array[CharacterModelVisual] = []
var _sisa_visual: CharacterModelVisual = null
var _warned: bool = false
var _distracted: bool = false
var _sneak: bool = false
var _distraction_done: bool = false
var _sneak_done: bool = false
var _dialogue_speaker: StringName = &""
var _dialogue_text: StringName = &""

var _enemies: Array[AmbushEnemy] = []
var _attack_ray: RayCast3D = null
var _sling: CombatWeapon = null
var _ambush_started: bool = false
var _completed: bool = false
var _dead: bool = false
var _blocking: bool = false
var _battle_drum: AudioStreamPlayer = null


func _ready() -> void:
	_build_landscape()
	player.global_position = Vector3(
		spawn.global_position.x,
		_height_at(spawn.global_position.x, spawn.global_position.z) + 0.15,
		spawn.global_position.z)
	hud.bind(player, player.stamina)
	_setup_player_combat()
	_setup_inventory_and_dialogue()
	CampaignProgress.apply(self)
	if CampaignProgress.is_respawn_pending():
		CampaignProgress.restore_checkpoint(self)
	if CampaignState.has_flag(&"carga_anca"):
		_apply_carry_penalty()
	_setup_camp()
	_setup_march()
	_setup_alternatives()
	_setup_enemies()
	_setup_trigger()
	_bind_environment()
	_setup_audio()
	hint_label.text = ""
	_warned = CampaignState.has_flag(&"mensajero_ayudado")
	if _warned:
		hud.show_subtitle(tr("PCH_PASO_WARNED"), 0.0)
	_update_status()
	CampaignProgress.save_checkpoint(self, player.global_position)
	SessionLog.mark(&"act", "paso")


## Indica si la emboscada está en curso.
func is_ambush_active() -> bool:
	return _ambush_started and not _completed and not _dead


## Indica si el acto se resolvió.
func is_completed() -> bool:
	return _completed


## Indica si el jugador cayó.
func is_dead() -> bool:
	return _dead


## Número de enemigos que siguen en pie.
func alive_enemies() -> int:
	var count: int = 0
	for enemy: AmbushEnemy in _enemies:
		if is_instance_valid(enemy) and enemy.is_alive():
			count += 1
	return count


## Aplica daño al jugador; el escudo reduce una parte y consume aliento.
func apply_player_damage(amount: float) -> void:
	if _dead or _completed or character == null:
		return
	var applied: float = amount
	if _blocking:
		applied *= PLAYER_DAMAGE_BLOCKED
		if player.stamina != null:
			player.stamina.consume(5.0)
	character.damage(applied)
	if hud != null:
		hud.flash_damage()
	if not character.is_alive():
		_dead = true
		hint_label.text = tr("PCH_PASO_DEAD")
	_update_status()


## Un enemigo se resolvió; actualiza la cuenta.
func on_enemy_resolved() -> void:
	_update_status()


func _physics_process(_delta: float) -> void:
	# Si el jugador rodea el disparador y cruza el paso, la emboscada se activa
	# igualmente: el acto no puede quedar bloqueado por una ruta lateral.
	if not _ambush_started and not _completed and not _dead \
			and player.global_position.z < -2.0:
		_start_ambush()
	if not is_ambush_active():
		return
	if alive_enemies() == 0:
		_finish_ambush()
	_update_status()


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		var mouse: InputEventMouseButton = event as InputEventMouseButton
		if mouse.button_index == MOUSE_BUTTON_LEFT and mouse.pressed:
			_attack()
			get_viewport().set_input_as_handled()
			return
		if mouse.button_index == MOUSE_BUTTON_RIGHT:
			_blocking = mouse.pressed
			get_viewport().set_input_as_handled()
			return
	if event.is_action_pressed("journal"):
		if hud == null or journal == null or dialogue == null or _completed or _dead:
			return
		if _ambush_started or hud.is_dialogue_open():
			return
		if hud.is_journal_open():
			hud.hide_journal()
			player.set_controls_locked(false)
		else:
			hud.show_journal(journal)
			player.set_controls_locked(true)
		get_viewport().set_input_as_handled()
		return
	if _completed and _advance_requested(event):
		get_viewport().set_input_as_handled()
		CampaignProgress.save(self)
		get_tree().change_scene_to_file("res://campaigns/01_pachacutec/scenes/world/ciudad.tscn")
		return
	if _dead and _retry_requested(event):
		get_viewport().set_input_as_handled()
		CampaignProgress.request_respawn()
		get_tree().reload_current_scene()


func _on_journal_closed() -> void:
	player.set_controls_locked(false)


func _attack() -> void:
	if not is_ambush_active() or player_combatant == null or _attack_ray == null:
		return
	if not player_combatant.can_attack():
		return
	var damage: float = player_combatant.attack(1.0)
	if damage <= 0.0:
		return
	player_combatant.register_hit()
	CampaignAudio.play_sfx(CampaignAudio.WHOOSH_PATH, -12.0)
	var hands: FirstPersonHands = player.get_node_or_null("Head/Camera3D/FirstPersonHands") as FirstPersonHands
	if hands != null:
		hands.play(&"attack")
	_attack_ray.force_raycast_update()
	if not _attack_ray.is_colliding():
		return
	var enemy: AmbushEnemy = _attack_ray.get_collider() as AmbushEnemy
	if enemy != null:
		CampaignAudio.play_sfx(CampaignAudio.IMPACT_PATH, -6.0)
		enemy.take_hit(damage)
	_update_status()


func _start_ambush() -> void:
	if _ambush_started or _completed or _dead:
		return
	_ambush_started = true
	var approach: String = "combate"
	if _sneak:
		approach = "sigilo"
	elif _distracted:
		approach = "distraccion"
	SessionLog.mark(&"ambush_start", approach)
	if _sneak:
		for enemy: AmbushEnemy in _enemies:
			enemy.take_hit(999.0)
		hud.show_subtitle(tr("PCH_PASO_SNEAK"), 0.0)
		_finish_ambush()
		return
	CampaignState.set_flag(&"paso_cruzado", 1)
	_start_drum()
	if _distracted:
		for index: int in range(2, _enemies.size()):
			_enemies[index].take_hit(999.0)
	hud.show_subtitle(tr("PCH_PASO_AMBUSH"), 0.0)
	_update_status()


func _finish_ambush() -> void:
	if _completed or _aftermath_pending:
		return
	_stop_drum()
	SessionLog.mark(&"ambush_end", "vivos=%d" % alive_enemies())
	_aftermath_pending = true
	CampaignProgress.save_checkpoint(self, player.global_position)
	hud.show_subtitle(tr("PCH_PASO_CLEAR"), 0.0)
	if dialogue != null and _aftermath_graph != null and dialogue.start(_aftermath_graph, &"start"):
		var target: Node3D = _camp_visuals[0] if not _camp_visuals.is_empty() else null
		player.begin_dialogue(target)
	else:
		_aftermath_pending = false
		_completed = true
		hint_label.text = tr("PCH_PASO_END")


func _update_status() -> void:
	if hud == null or character == null:
		return
	# Solo durante la emboscada: fuera de ella el HUD queda limpio.
	if not _ambush_started or _completed or _dead:
		hud.set_status("")
		return
	hud.set_status(tr("PCH_PASO_COMBAT_STATUS") % alive_enemies())


func _setup_player_combat() -> void:
	character = CharacterState.new()
	character.name = "CharacterState"
	player.add_child(character)
	_sling = CombatWeapon.new()
	_sling.kind = CombatWeapon.Kind.SLING
	_sling.damage_min = 18.0
	_sling.damage_max = 32.0
	_sling.range_min = 3.0
	_sling.range_max = 28.0
	_sling.charge_full_seconds = 1.2
	_sling.stamina_cost = 10.0
	_sling.cooldown_seconds = 0.8
	player_combatant = Combatant.new()
	player_combatant.name = "PlayerCombatant"
	player_combatant.character = character
	player_combatant.weapon = _sling
	player_combatant.stamina = player.stamina
	player.add_child(player_combatant)
	var camera: Camera3D = player.get_node_or_null("Head/Camera3D") as Camera3D
	if camera != null:
		_attack_ray = RayCast3D.new()
		_attack_ray.name = "AttackRay"
		_attack_ray.target_position = Vector3(0.0, 0.0, -30.0)
		_attack_ray.collision_mask = 9
		_attack_ray.enabled = true
		camera.add_child(_attack_ray)


func _setup_inventory_and_dialogue() -> void:
	inventory = Inventory.new()
	inventory.name = "Inventory"
	player.add_child(inventory)
	var coca: ItemDefinition = ItemDefinition.new()
	coca.id = &"coca"
	coca.category = ItemDefinition.Category.CONSUMABLE
	coca.max_stack = 5
	coca.name_key = &"PCH_ITEM_COCA"
	coca.description_key = &"PCH_ITEM_COCA_DESC"
	coca.stamina_restore = 25.0
	coca.morale_change = -5.0
	inventory.add(coca, 2)
	journal = Journal.new()
	journal.name = "Journal"
	player.add_child(journal)
	hud.journal_closed.connect(_on_journal_closed)
	dialogue = DialogueRunner.new()
	dialogue.name = "DialogueRunner"
	dialogue.character = character
	dialogue.inventory = inventory
	player.add_child(dialogue)
	dialogue.line_shown.connect(_on_dialogue_line)
	dialogue.choices_shown.connect(_on_dialogue_choices)
	dialogue.finished.connect(_on_dialogue_finished)
	dialogue.flag_changed.connect(_on_dialogue_flag)
	hud.dialogue_advanced.connect(_on_dialogue_advanced)
	hud.dialogue_choice.connect(_on_dialogue_choice)
	_camp_graph = _build_camp_dialogue()
	_aftermath_graph = _build_aftermath_dialogue()


func _setup_camp() -> void:
	var ground: float = _height_at(CAMP_POSITION.x, CAMP_POSITION.z)
	# Foso de ceniza y dos lenguas de fuego: una llama no es un cono ancho.
	var pit: MeshInstance3D = MeshInstance3D.new()
	var pit_mesh: CylinderMesh = CylinderMesh.new()
	pit_mesh.top_radius = 0.55
	pit_mesh.bottom_radius = 0.5
	pit_mesh.height = 0.12
	pit.mesh = pit_mesh
	pit.position = Vector3(CAMP_POSITION.x, ground + 0.06, CAMP_POSITION.z)
	var ash: StandardMaterial3D = StandardMaterial3D.new()
	ash.albedo_color = Color(0.12, 0.1, 0.08, 1.0)
	ash.roughness = 1.0
	pit.material_override = ash
	add_child(pit)
	for flame_size: Vector2 in [Vector2(0.24, 0.55), Vector2(0.14, 0.38)]:
		var flame: MeshInstance3D = MeshInstance3D.new()
		var flame_mesh: CylinderMesh = CylinderMesh.new()
		flame_mesh.top_radius = 0.0
		flame_mesh.bottom_radius = flame_size.x
		flame_mesh.height = flame_size.y
		flame.mesh = flame_mesh
		flame.position = Vector3(CAMP_POSITION.x, ground + 0.12 + flame_size.y * 0.5, CAMP_POSITION.z)
		var flame_material: StandardMaterial3D = StandardMaterial3D.new()
		flame_material.albedo_color = Color(0.98, 0.52, 0.16, 1.0)
		flame_material.emission_enabled = true
		flame_material.emission = Color(1.0, 0.42, 0.1, 1.0)
		flame_material.emission_energy_multiplier = 2.2
		flame.material_override = flame_material
		add_child(flame)
	var light: OmniLight3D = OmniLight3D.new()
	light.position = Vector3(CAMP_POSITION.x, ground + 1.4, CAMP_POSITION.z)
	light.light_color = Color(1.0, 0.62, 0.32, 1.0)
	light.light_energy = 1.4
	light.omni_range = 7.0
	add_child(light)
	# Anillo de piedras y dos troncos: el fuego se apoya en el suelo, no flota.
	var stone: ShaderMaterial = SurfaceMaterials.layer_material(SurfaceMaterials.Layer.ROCK, Color(0.5, 0.48, 0.45, 1.0))
	for index: int in range(7):
		var angle: float = TAU * float(index) / 7.0
		var rock: MeshInstance3D = MeshInstance3D.new()
		var sphere: SphereMesh = SphereMesh.new()
		sphere.radius = 0.16
		sphere.height = 0.3
		sphere.radial_segments = 6
		sphere.rings = 3
		rock.mesh = sphere
		rock.material_override = stone
		rock.position = Vector3(CAMP_POSITION.x + cos(angle) * 0.8, ground + 0.08, CAMP_POSITION.z + sin(angle) * 0.8)
		add_child(rock)
	var wood: ShaderMaterial = SurfaceMaterials.layer_material(SurfaceMaterials.Layer.WOOD, Color(0.36, 0.26, 0.17, 1.0))
	for offset: Vector3 in [Vector3(-1.1, 0.0, 0.5), Vector3(1.0, 0.0, -0.6)]:
		var fire_log: MeshInstance3D = MeshInstance3D.new()
		var log_mesh: CylinderMesh = CylinderMesh.new()
		log_mesh.top_radius = 0.09
		log_mesh.bottom_radius = 0.11
		log_mesh.height = 1.0
		fire_log.mesh = log_mesh
		fire_log.material_override = wood
		fire_log.position = Vector3(CAMP_POSITION.x + offset.x, ground + 0.12, CAMP_POSITION.z + offset.z)
		fire_log.rotation_degrees = Vector3(0.0, 0.0, 90.0)
		add_child(fire_log)
	_camp_visuals.append(_add_camp_npc(Vector3(-5.4, 0.0, 17.2), &"curaca", 0))
	_camp_visuals.append(_add_camp_npc(Vector3(-2.6, 0.0, 17.4), &"farmer", 0))
	_camp_visuals.append(_add_camp_npc(Vector3(-4.2, 0.0, 19.4), &"messenger", 0))
	var instance: Node = (load(CAMP_SCENE) as PackedScene).instantiate()
	var camp: CampPoint = instance as CampPoint
	var body: Node3D = instance as Node3D
	if camp == null or body == null:
		instance.free()
		return
	body.position = CAMP_POSITION
	add_child(camp)
	if not _camp_visuals.is_empty():
		camp.highlight_target = _camp_visuals[0]
	camp.requested.connect(_on_camp_requested)


func _add_camp_npc(at: Vector3, role: StringName, variant: int) -> CharacterModelVisual:
	var visual: CharacterModelVisual = CharacterModelVisual.new()
	visual.name = "CampVisual"
	visual.model_path = "res://campaigns/01_pachacutec/assets/models/" + _camp_model_for(role, variant)
	visual.position = Vector3(at.x, _height_at(at.x, at.z), at.z)
	add_child(visual)
	var target: Vector3 = Vector3(CAMP_POSITION.x, visual.position.y, CAMP_POSITION.z)
	if visual.position.distance_to(target) > 0.1:
		visual.look_at(target, Vector3.UP)
	return visual


static func _camp_model_for(role: StringName, variant: int) -> String:
	match role:
		&"farmer":
			return "pch_npc_farmer.glb"
		&"messenger":
			return "pch_npc_messenger.glb"
		&"curaca":
			return "pch_npc_curaca.glb"
	match variant % 3:
		1:
			return "pch_npc_villager_b.glb"
		2:
			return "pch_npc_villager_c.glb"
	return "pch_npc_villager.glb"

func _on_camp_requested() -> void:
	if dialogue == null or _camp_graph == null or _completed or _dead:
		return
	if dialogue.is_active():
		return
	if dialogue.start(_camp_graph):
		CampaignProgress.save_checkpoint(self, player.global_position)
		var target: Node3D = _camp_visuals[0] if not _camp_visuals.is_empty() else null
		player.begin_dialogue(target)


func _build_camp_dialogue() -> DialogueGraph:
	var graph: DialogueGraph = DialogueGraph.new()
	graph.entry_id = &"start"
	var start: DialogueNode = DialogueNode.new()
	start.id = &"start"
	start.speaker_key = &"PCH_NPC_CURACA"
	start.text_key = &"PCH_CAMP_INTRO"
	start.next_id = &"end"
	var water: DialogueChoice = DialogueChoice.new()
	water.text_key = &"PCH_PASO_WATER"
	water.next_id = &"water"
	water.conditions = _conditions([_item_condition(&"agua")])
	var maize: DialogueChoice = DialogueChoice.new()
	maize.text_key = &"PCH_PASO_MAIZE"
	maize.next_id = &"maize"
	maize.conditions = _conditions([_item_condition(&"maiz")])
	var manta: DialogueChoice = DialogueChoice.new()
	manta.text_key = &"PCH_PASO_MANTA"
	manta.next_id = &"manta"
	manta.conditions = _conditions([_item_condition(&"manta")])
	var rest: DialogueChoice = DialogueChoice.new()
	rest.text_key = &"PCH_CAMP_REST"
	rest.next_id = &"rest"
	var push: DialogueChoice = DialogueChoice.new()
	push.text_key = &"PCH_CAMP_PUSH"
	push.next_id = &"push"
	var share: DialogueChoice = DialogueChoice.new()
	share.text_key = &"PCH_CAMP_COCA"
	share.next_id = &"coca"
	var coca_condition: DialogueCondition = DialogueCondition.new()
	coca_condition.kind = DialogueCondition.Kind.ITEM
	coca_condition.key = &"coca"
	coca_condition.minimum = 1
	var coca_conditions: Array[DialogueCondition] = [coca_condition]
	share.conditions = coca_conditions
	var leave: DialogueChoice = DialogueChoice.new()
	leave.text_key = &"PCH_DLG_LEAVE"
	leave.next_id = &"end"
	# El panel admite cuatro opciones. La primera página cubre los recursos; la
	# segunda, las decisiones de marcha. Así no se pierde «Compartir coca» ni
	# «Otro día será» y «Descansar» no se repite.
	var more: DialogueChoice = DialogueChoice.new()
	more.text_key = &"PCH_CAMP_MORE"
	more.next_id = &"more"
	var choices: Array[DialogueChoice] = [water, maize, manta, more]
	start.choices = choices
	var water_node: DialogueNode = _dialogue_answer(&"water", &"PCH_PASO_WATER_DONE", &"agua_bebida")
	_append_effect(water_node, _item_remove_effect(&"agua"))
	var maize_node: DialogueNode = _dialogue_answer(&"maize", &"PCH_PASO_MAIZE_DONE", &"maiz_comido")
	_append_effect(maize_node, _item_remove_effect(&"maiz"))
	var manta_node: DialogueNode = _dialogue_answer(&"manta", &"PCH_PASO_MANTA_DONE", &"manta_usada")
	var rest_node: DialogueNode = _dialogue_answer(&"rest", &"PCH_CAMP_REST_DONE", &"descanso")
	var push_node: DialogueNode = _dialogue_answer(&"push", &"PCH_CAMP_PUSH_DONE", &"marcha_nocturna")
	var coca_node: DialogueNode = _dialogue_answer(&"coca", &"PCH_CAMP_COCA_DONE", &"coca_compartida")
	var coca_effect: DialogueEffect = DialogueEffect.new()
	coca_effect.kind = DialogueEffect.Kind.ITEM_REMOVE
	coca_effect.key = &"coca"
	coca_effect.amount = 1
	var coca_effects: Array[DialogueEffect] = coca_node.effects
	coca_effects.append(coca_effect)
	coca_node.effects = coca_effects
	var more_node: DialogueNode = DialogueNode.new()
	more_node.id = &"more"
	more_node.speaker_key = &"PCH_NPC_CURACA"
	more_node.text_key = &"PCH_CAMP_MORE_TEXT"
	var more_choices: Array[DialogueChoice] = [rest, push, share, leave]
	more_node.choices = more_choices
	var nodes: Array[DialogueNode] = [
		start, water_node, maize_node, manta_node, rest_node, push_node, coca_node, more_node,
	]
	graph.nodes = nodes
	return graph


func _build_aftermath_dialogue() -> DialogueGraph:
	var graph: DialogueGraph = DialogueGraph.new()
	graph.entry_id = &"start"
	var start: DialogueNode = DialogueNode.new()
	start.id = &"start"
	start.speaker_key = &"PCH_NPC_CURACA"
	start.text_key = &"PCH_AFTER_INTRO"
	start.next_id = &"end"
	var carry: DialogueChoice = DialogueChoice.new()
	carry.text_key = &"PCH_AFTER_CARRY"
	carry.next_id = &"wounded_carry"
	var leave: DialogueChoice = DialogueChoice.new()
	leave.text_key = &"PCH_AFTER_LEAVE"
	leave.next_id = &"wounded_leave"
	# Dejarlo «con agua y coca» exige llevar ambas cosas y las consume. Si no
	# las hay, la única salida es cargarlo: la biblia §5 lo dice así.
	leave.conditions = _conditions([
		_item_condition(&"agua"), _item_condition(&"coca"),
	])
	var choices: Array[DialogueChoice] = [carry, leave]
	start.choices = choices
	var carry_node: DialogueNode = _dialogue_answer(&"wounded_carry", &"PCH_AFTER_WOUNDED_CARRY", &"herido_salvado")
	carry_node.next_id = &"maize"
	var leave_node: DialogueNode = _dialogue_answer(&"wounded_leave", &"PCH_AFTER_WOUNDED_LEAVE", &"herido_dejado")
	leave_node.next_id = &"maize"
	var maize: DialogueNode = DialogueNode.new()
	maize.id = &"maize"
	maize.speaker_key = &"PCH_NPC_CURACA"
	maize.text_key = &"PCH_AFTER_MAIZE"
	maize.next_id = &"end"
	var keep: DialogueChoice = DialogueChoice.new()
	keep.text_key = &"PCH_AFTER_KEEP"
	keep.next_id = &"maize_keep"
	var abandon: DialogueChoice = DialogueChoice.new()
	abandon.text_key = &"PCH_AFTER_ABANDON"
	abandon.next_id = &"maize_abandon"
	var maize_choices: Array[DialogueChoice] = [keep, abandon]
	maize.choices = maize_choices
	var keep_node: DialogueNode = _dialogue_answer(&"maize_keep", &"PCH_AFTER_MAIZE_KEEP", &"maiz_guardado")
	keep_node.next_id = &"scout"
	var abandon_node: DialogueNode = _dialogue_answer(&"maize_abandon", &"PCH_AFTER_MAIZE_ABANDON", &"maiz_abandonado")
	abandon_node.next_id = &"scout"
	# El explorador chanca herido no cambia la batalla, pero sí una línea del
	# acto III (biblia §5.3).
	var scout: DialogueNode = DialogueNode.new()
	scout.id = &"scout"
	scout.speaker_key = &"PCH_NPC_CURACA"
	scout.text_key = &"PCH_AFTER_SCOUT"
	scout.next_id = &"end"
	var spare: DialogueChoice = DialogueChoice.new()
	spare.text_key = &"PCH_AFTER_SPARE"
	spare.next_id = &"scout_spared"
	var ignore: DialogueChoice = DialogueChoice.new()
	ignore.text_key = &"PCH_AFTER_LEAVE_SCOUT"
	ignore.next_id = &"end"
	var scout_choices: Array[DialogueChoice] = [spare, ignore]
	scout.choices = scout_choices
	var spare_node: DialogueNode = _dialogue_answer(&"scout_spared", &"PCH_AFTER_SPARED", &"scout_spared")
	var nodes: Array[DialogueNode] = [start, carry_node, leave_node, maize, keep_node, abandon_node, scout, spare_node]
	graph.nodes = nodes
	return graph


func _dialogue_answer(node_id: StringName, text_key: StringName, flag_key: StringName) -> DialogueNode:
	var node: DialogueNode = DialogueNode.new()
	node.id = node_id
	node.speaker_key = &"PCH_NPC_CURACA"
	node.text_key = text_key
	node.next_id = &"end"
	var effect: DialogueEffect = DialogueEffect.new()
	effect.kind = DialogueEffect.Kind.SET_FLAG
	effect.key = flag_key
	effect.amount = 1
	var effects: Array[DialogueEffect] = [effect]
	node.effects = effects
	return node


func _on_dialogue_line(speaker_key: StringName, text_key: StringName) -> void:
	_dialogue_speaker = speaker_key
	_dialogue_text = text_key
	var empty: Array[String] = []
	hud.show_dialogue(tr(String(speaker_key)), tr(String(text_key)), empty)


func _on_dialogue_choices(text_keys: Array[StringName]) -> void:
	var texts: Array[String] = []
	for key: StringName in text_keys:
		texts.append(tr(String(key)))
	hud.update_dialogue(tr(String(_dialogue_speaker)), tr(String(_dialogue_text)), texts)


func _on_dialogue_advanced() -> void:
	if dialogue != null:
		dialogue.advance()


func _on_dialogue_choice(index: int) -> void:
	if dialogue != null:
		dialogue.choose(index)


func _on_dialogue_finished() -> void:
	hud.hide_dialogue()
	player.end_dialogue()
	_stop_drum()
	if _aftermath_pending:
		_aftermath_pending = false
		_completed = true
		hint_label.text = tr("PCH_PASO_END")


func _on_dialogue_flag(key: StringName, value: int) -> void:
	CampaignState.set_flag(key, value)
	SessionLog.mark(&"flag", "%s=%d" % [String(key), value])
	if value == 0 or character == null:
		return
	if key == &"descanso":
		character.heal(25.0)
	elif key == &"herido_salvado":
		_apply_carry_penalty()
		CampaignState.set_flag(&"carga_anca", 1)
		hud.show_hint(tr("PCH_AFTER_CARRY_COST"), 3.0)
	elif key == &"herido_dejado":
		_apply_leave_cost()
		hud.show_hint(tr("PCH_AFTER_LEAVE_COST"), 3.0)
	elif key == &"agua_bebida":
		character.heal(10.0)
		if player.stamina != null:
			player.stamina.restore(30.0)
	elif key == &"maiz_comido":
		character.change_morale(15.0)
	elif key == &"maiz_abandonado":
		# Abandonar la carga aligera la huida: el jugador camina y corre algo más.
		player.walk_speed += 0.4
		player.run_speed += 0.6
	elif key == &"manta_usada":
		character.change_morale(10.0)
	elif key == &"marcha_nocturna":
		character.change_morale(-5.0)
	elif key == &"coca_compartida" or key == &"marcha_sisa":
		var trust: int = mini(CampaignState.get_flag(&"confianza_sisa") + 1, 2)
		CampaignState.set_flag(&"confianza_sisa", trust)
		if key == &"marcha_sisa":
			character.register_skill_use(&"monte", 2)


## Cargar a Anca reduce el aliento máximo durante todo el acto II: no es un
## coste de un instante. La penalización se reaplica al reaparecer.
func _apply_carry_penalty() -> void:
	if player.stamina == null:
		return
	var current: float = player.stamina.get_current()
	player.stamina.max_stamina = 75.0
	if current > 75.0:
		player.stamina.consume(current - 75.0)
	else:
		player.stamina.stamina_changed.emit(current, 75.0)
	if character != null:
		character.damage(5.0)


## Dejar a Anca cuesta las provisiones que se le quedan y reputación.
func _apply_leave_cost() -> void:
	if inventory != null:
		if inventory.has(&"agua"):
			inventory.remove(&"agua", 1)
		if inventory.has(&"coca"):
			inventory.remove(&"coca", 1)
	if character != null:
		character.change_reputation(&"llacta", -1)
		character.change_morale(-5.0)


## II.1: Sisa comparte el camino antes de la emboscada.
func _setup_march() -> void:
	_sisa_visual = _add_camp_npc(Vector3(2.0, 0.0, 28.0), &"villager", 0)
	var instance: Node = (load(CAMP_SCENE) as PackedScene).instantiate()
	var point: CampPoint = instance as CampPoint
	var body: Node3D = instance as Node3D
	if point == null or body == null:
		instance.free()
		return
	point.name = "SisaPoint"
	point.prompt_key = &"PCH_PASO_TALK_SISA"
	body.position = Vector3(2.0, 0.9, 28.0)
	add_child(point)
	point.highlight_target = _sisa_visual
	point.requested.connect(_on_march_requested)


func _on_march_requested() -> void:
	if dialogue == null or _ambush_started or _completed or _dead:
		return
	if dialogue.is_active():
		return
	if dialogue.start(_build_march_dialogue()):
		player.begin_dialogue(_sisa_visual)


func _build_march_dialogue() -> DialogueGraph:
	var graph: DialogueGraph = DialogueGraph.new()
	graph.entry_id = &"start"
	var start: DialogueNode = DialogueNode.new()
	start.id = &"start"
	start.speaker_key = &"PCH_NPC_SISA"
	start.text_key = &"PCH_PASO_MARCH_INTRO"
	start.next_id = &"end"
	var listen: DialogueChoice = DialogueChoice.new()
	listen.text_key = &"PCH_PASO_MARCH_LISTEN"
	listen.next_id = &"listen"
	var silent: DialogueChoice = DialogueChoice.new()
	silent.text_key = &"PCH_PASO_MARCH_SILENT"
	silent.next_id = &"silent"
	var choices: Array[DialogueChoice] = [listen, silent]
	start.choices = choices
	var listen_node: DialogueNode = DialogueNode.new()
	listen_node.id = &"listen"
	listen_node.speaker_key = &"PCH_NPC_SISA"
	listen_node.text_key = &"PCH_PASO_MARCH_LISTEN_ANSWER"
	listen_node.next_id = &"end"
	var listen_effect: DialogueEffect = DialogueEffect.new()
	listen_effect.kind = DialogueEffect.Kind.SET_FLAG
	listen_effect.key = &"marcha_sisa"
	listen_effect.amount = 1
	var listen_effects: Array[DialogueEffect] = [listen_effect]
	listen_node.effects = listen_effects
	var silent_node: DialogueNode = DialogueNode.new()
	silent_node.id = &"silent"
	silent_node.speaker_key = &"PCH_NPC_SISA"
	silent_node.text_key = &"PCH_PASO_MARCH_SILENT_ANSWER"
	silent_node.next_id = &"end"
	var nodes: Array[DialogueNode] = [start, listen_node, silent_node]
	graph.nodes = nodes
	return graph


func _item_condition(key: StringName) -> DialogueCondition:
	var condition: DialogueCondition = DialogueCondition.new()
	condition.kind = DialogueCondition.Kind.ITEM
	condition.key = key
	condition.minimum = 1
	return condition


func _conditions(items: Array[DialogueCondition]) -> Array[DialogueCondition]:
	return items


func _item_remove_effect(key: StringName) -> DialogueEffect:
	var effect: DialogueEffect = DialogueEffect.new()
	effect.kind = DialogueEffect.Kind.ITEM_REMOVE
	effect.key = key
	effect.amount = 1
	return effect


func _append_effect(node: DialogueNode, effect: DialogueEffect) -> void:
	var effects: Array[DialogueEffect] = node.effects
	effects.append(effect)
	node.effects = effects


func _setup_alternatives() -> void:
	_add_alternative("DistractPoint", DISTRACT_POSITION, &"PCH_PASO_TALK_DISTRACT", _on_distract_requested)
	_add_alternative("SneakPoint", SNEAK_POSITION, &"PCH_PASO_TALK_SNEAK", _on_sneak_requested)


func _add_alternative(node_name: String, at: Vector3, prompt_key: StringName, handler: Callable) -> void:
	var instance: Node = (load(CAMP_SCENE) as PackedScene).instantiate()
	var point: CampPoint = instance as CampPoint
	var body: Node3D = instance as Node3D
	if point == null or body == null:
		instance.free()
		return
	point.name = node_name
	point.prompt_key = prompt_key
	body.position = at
	add_child(point)
	_add_alternative_marker(point, node_name)
	point.requested.connect(handler)


## Piedras apiladas para el arroyo y un rollo de cuerda para la distracción:
## las alternativas dejan de ser cajas invisibles en el camino.
func _add_alternative_marker(point: CampPoint, node_name: String) -> void:
	var root: Node3D = Node3D.new()
	root.name = "Marker"
	root.position = Vector3(0.0, -0.78, 0.0)
	point.add_child(root)
	var rock: ShaderMaterial = SurfaceMaterials.layer_material(
		SurfaceMaterials.Layer.ROCK, Color(0.50, 0.47, 0.43, 1.0))
	if node_name == "SneakPoint":
		for index: int in range(3):
			var stone: MeshInstance3D = MeshInstance3D.new()
			var sphere: SphereMesh = SphereMesh.new()
			sphere.radius = 0.15 - float(index) * 0.03
			sphere.height = 0.22 - float(index) * 0.04
			sphere.radial_segments = 6
			sphere.rings = 3
			stone.mesh = sphere
			stone.material_override = rock
			stone.position = Vector3(0.0, 0.08 + float(index) * 0.12, 0.0)
			stone.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
			root.add_child(stone)
		return
	var wood: ShaderMaterial = SurfaceMaterials.layer_material(
		SurfaceMaterials.Layer.WOOD, Color(0.42, 0.30, 0.19, 1.0))
	var coil: MeshInstance3D = MeshInstance3D.new()
	var cylinder: CylinderMesh = CylinderMesh.new()
	cylinder.top_radius = 0.24
	cylinder.bottom_radius = 0.24
	cylinder.height = 0.06
	cylinder.radial_segments = 14
	coil.mesh = cylinder
	coil.material_override = wood
	coil.position = Vector3(0.0, 0.09, 0.0)
	coil.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	root.add_child(coil)


func _on_distract_requested() -> void:
	if _distraction_done or _ambush_started or _completed or _dead:
		return
	if dialogue != null and dialogue.is_active():
		return
	_distraction_done = true
	_distracted = true
	if inventory != null and inventory.has(&"cuerda"):
		inventory.remove(&"cuerda", 1)
		hud.show_subtitle(tr("PCH_PASO_DISTRACT_CUERDA"), 0.0)
	else:
		hud.show_subtitle(tr("PCH_PASO_DISTRACT"), 0.0)


func _on_sneak_requested() -> void:
	if _sneak_done or _ambush_started or _completed or _dead:
		return
	if dialogue != null and dialogue.is_active():
		return
	if character == null:
		hud.show_subtitle(tr("PCH_PASO_SNEAK_FAIL"), 0.0)
		return
	if character.get_skill(&"monte") < 2 and not _warned:
		hud.show_subtitle(tr("PCH_PASO_SNEAK_FAIL"), 0.0)
		return
	_sneak_done = true
	_sneak = true
	CampaignState.set_flag(&"mensaje_chanca", 1)
	CampaignState.set_flag(&"paso_cruzado", 1)
	hud.show_subtitle(tr("PCH_PASO_SNEAK_INFO"), 0.0)


func _setup_enemies() -> void:
	for index: int in range(ENEMY_POSITIONS.size()):
		var enemy: AmbushEnemy = AmbushEnemy.new()
		enemy.name = "Ambusher%d" % (index + 1)
		var at: Vector3 = ENEMY_POSITIONS[index]
		enemy.position = Vector3(at.x, _height_at(at.x, at.z), at.z)
		add_child(enemy)
		enemy.setup(player, self)
		_enemies.append(enemy)


func _setup_trigger() -> void:
	var trigger: Area3D = Area3D.new()
	trigger.name = "AmbushTrigger"
	trigger.collision_layer = 0
	trigger.collision_mask = 2
	# El disparador va al norte de las alternativas: el jugador debe poder
	# elegir sigilo o distracción antes de entrar en la emboscada.
	trigger.position = Vector3(0.0, _height_at(0.0, 0.0) + 2.0, 0.0)
	var shape: CollisionShape3D = CollisionShape3D.new()
	var box: BoxShape3D = BoxShape3D.new()
	box.size = Vector3(14.0, 4.0, 4.0)
	shape.shape = box
	trigger.add_child(shape)
	add_child(trigger)
	trigger.body_entered.connect(_on_trigger_entered)


func _on_trigger_entered(body: Node3D) -> void:
	if body == player:
		_start_ambush()


func _build_landscape() -> void:
	_build_terrain()
	_build_path_areas()
	_build_stream()
	_build_rocks()
	_build_shelter()
	_build_vegetation()
	_build_bounds()
	_build_clouds()


## Altura del terreno en [param x], [param z]. Pública para las pruebas y la
## vegetación.
func height_at(x: float, z: float) -> float:
	return _height_at(x, z)


## Altura del paso: corredor llano, paredes de roca a los lados, cresta al
## norte y al sur, y el cauce del arroyo encajado al oeste.
func _height_at(x: float, z: float) -> float:
	# Primera pared del paso y, detrás, una cresta alta que cierra el horizonte.
	var wall: float = smoothstep(16.0, 26.0, absf(x)) * 14.0
	var outer: float = smoothstep(28.0, 55.0, absf(x)) * (18.0 + 3.0 * sin(z * 0.13) + 2.0 * cos(z * 0.07))
	var crest: float = smoothstep(31.0, 42.0, absf(z)) * 8.0
	var outer_crest: float = smoothstep(44.0, 70.0, absf(z)) * (16.0 + 3.0 * sin(x * 0.11))
	var stream: float = -0.85 * exp(-pow((x - STREAM_X) / 2.2, 2.0))
	var relief: float = 0.35 * sin(x * 0.12) * cos(z * 0.09) + 0.16 * sin((x - z) * 0.21)
	var smooth_path: float = 1.0 - smoothstep(0.0, 5.0, absf(x)) * 0.55
	return wall + outer + crest + outer_crest + stream + relief * smooth_path


func _build_terrain() -> void:
	var terrain: Node3D = Node3D.new()
	terrain.name = "Terrain"
	add_child(terrain)
	var surface: SurfaceTool = SurfaceTool.new()
	surface.begin(Mesh.PRIMITIVE_TRIANGLES)
	var step: float = TERRAIN_SIZE / float(TERRAIN_RESOLUTION)
	var half: float = TERRAIN_SIZE * 0.5
	for zi: int in range(TERRAIN_RESOLUTION):
		for xi: int in range(TERRAIN_RESOLUTION):
			var x0: float = -half + step * float(xi)
			var z0: float = -half + step * float(zi)
			var x1: float = x0 + step
			var z1: float = z0 + step
			var p00: Vector3 = Vector3(x0, _height_at(x0, z0), z0)
			var p10: Vector3 = Vector3(x1, _height_at(x1, z0), z0)
			var p01: Vector3 = Vector3(x0, _height_at(x0, z1), z1)
			var p11: Vector3 = Vector3(x1, _height_at(x1, z1), z1)
			for vertex: Vector3 in [p00, p10, p11, p00, p11, p01]:
				surface.add_vertex(vertex)
	surface.generate_normals()
	var mesh: ArrayMesh = surface.commit()
	var mesh_instance: MeshInstance3D = MeshInstance3D.new()
	mesh_instance.name = "TerrainMesh"
	mesh_instance.mesh = mesh
	var material: ShaderMaterial = SurfaceMaterials.terrain_material(GRASS_COLOR, ROCK_COLOR, DIRT_COLOR)
	material.set_shader_parameter("steep_height_range", Vector2(2.5, 6.0))
	# El paso tiene laderas muy tendidas: el detalle triplanar se repite si se
	# lee a escala de sendero. Se baja el detalle y se sube la variación macro.
	material.set_shader_parameter("detail_strength", 0.25)
	material.set_shader_parameter("normal_strength", 0.12)
	material.set_shader_parameter("macro_scale", 0.18)
	material.set_shader_parameter("macro_strength", 0.65)
	mesh_instance.material_override = material
	# El terreno recibe sombra pero no la proyecta: es la malla más grande del
	# mapa y su sombra no aporta volumen frente a rocas, vegetación y refugio.
	mesh_instance.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	terrain.add_child(mesh_instance)
	var body: StaticBody3D = StaticBody3D.new()
	body.name = "TerrainBody"
	body.collision_layer = 1
	body.collision_mask = 0
	var collision: CollisionShape3D = CollisionShape3D.new()
	collision.name = "TerrainCollision"
	collision.shape = mesh.create_trimesh_shape()
	body.add_child(collision)
	terrain.add_child(body)


## Sendero, campamento y refugio se pintan sobre el terreno como tierra
## apisonada; las cajas quedan ocultas y solo aportan el rectángulo.
func _build_path_areas() -> void:
	var areas: Array[MeshInstance3D] = [
		_add_overlay_box("PathArea", Vector3(0.0, 0.05, 0.0), Vector3(4.2, 0.1, 68.0)),
		_add_overlay_box("CampArea", Vector3(-4.0, 0.05, 18.0), Vector3(11.0, 0.1, 10.0)),
		_add_overlay_box("ShelterArea", Vector3(13.0, 0.05, 0.0), Vector3(6.0, 0.1, 8.0)),
	]
	var terrain_mesh: MeshInstance3D = get_node_or_null("Terrain/TerrainMesh") as MeshInstance3D
	if terrain_mesh != null and terrain_mesh.material_override is ShaderMaterial:
		SurfaceMaterials.set_overlay_areas(terrain_mesh.material_override as ShaderMaterial, areas)


func _add_overlay_box(box_name: String, at: Vector3, size: Vector3) -> MeshInstance3D:
	var mesh_instance: MeshInstance3D = MeshInstance3D.new()
	mesh_instance.name = box_name
	var box: BoxMesh = BoxMesh.new()
	box.size = size
	mesh_instance.mesh = box
	mesh_instance.position = at
	mesh_instance.visible = false
	add_child(mesh_instance)
	return mesh_instance


func _build_stream() -> void:
	var water: MeshInstance3D = MeshInstance3D.new()
	water.name = "Stream"
	var plane: PlaneMesh = PlaneMesh.new()
	plane.size = Vector2(5.2, 66.0)
	water.mesh = plane
	water.position = Vector3(STREAM_X, WATER_LEVEL, 0.0)
	var material: StandardMaterial3D = StandardMaterial3D.new()
	material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	material.albedo_color = WATER_COLOR
	material.roughness = 0.08
	material.metallic = 0.15
	material.cull_mode = BaseMaterial3D.CULL_DISABLED
	water.material_override = material
	add_child(water)


func _build_rocks() -> void:
	for index: int in range(ROCK_POSITIONS.size()):
		var radius: float = 1.1 + 0.3 * float(index % 3)
		_add_boulder(ROCK_POSITIONS[index], radius, 100 + index)
	# Piedras sueltas en las dos orillas del arroyo.
	for index: int in range(-3, 4):
		var z: float = float(index) * 8.0
		_add_boulder(Vector3(-17.2, 0.0, z), 0.65, 200 + index)
		_add_boulder(Vector3(-10.8, 0.0, z + 3.0), 0.55, 300 + index)


## Roca de campo: esfera deformada de forma determinista y con colisión.
func _add_boulder(center: Vector3, radius: float, boulder_seed: int) -> void:
	var sphere: SphereMesh = SphereMesh.new()
	sphere.radius = radius
	sphere.height = radius * 2.0
	sphere.radial_segments = 10
	sphere.rings = 6
	var arrays: Array = sphere.get_mesh_arrays()
	var vertices: PackedVector3Array = arrays[Mesh.ARRAY_VERTEX]
	for index: int in range(vertices.size()):
		var vertex: Vector3 = vertices[index]
		var wobble: float = 1.0 + 0.14 * sin(vertex.x * 7.3 + float(boulder_seed)) * cos(vertex.z * 6.1 - float(boulder_seed))
		vertices[index] = Vector3(vertex.x, vertex.y * 0.72, vertex.z) * wobble
	arrays[Mesh.ARRAY_VERTEX] = vertices
	var source: ArrayMesh = ArrayMesh.new()
	source.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arrays)
	var surface: SurfaceTool = SurfaceTool.new()
	surface.create_from(source, 0)
	surface.generate_normals()
	var mesh: ArrayMesh = surface.commit()
	mesh.surface_set_material(0, SurfaceMaterials.layer_material(SurfaceMaterials.Layer.ROCK, Color(0.52, 0.50, 0.47, 1.0)))
	var base: Vector3 = Vector3(center.x, _height_at(center.x, center.z) + radius * 0.28, center.z)
	var instance: MeshInstance3D = MeshInstance3D.new()
	instance.name = "Boulder%d" % boulder_seed
	instance.mesh = mesh
	instance.position = base
	add_child(instance)
	var body: StaticBody3D = StaticBody3D.new()
	body.name = "BoulderBody%d" % boulder_seed
	body.collision_layer = 1
	body.collision_mask = 0
	body.position = base + Vector3(0.0, radius * 0.25, 0.0)
	var shape: CollisionShape3D = CollisionShape3D.new()
	var sphere_shape: SphereShape3D = SphereShape3D.new()
	sphere_shape.radius = radius * 0.85
	shape.shape = sphere_shape
	body.add_child(shape)
	add_child(body)


## Refugio abierto de pirca seca: tres muros, techo de lajas y vigas de madera.
func _build_shelter() -> void:
	var ground: float = _height_at(14.0, 0.0)
	var faces: Array[StoneWall.Face] = [
		StoneWall.Face.new(Vector3(14.2, ground, -2.5), Vector3(0.0, 0.0, 1.0), Vector3(-1.0, 0.0, 0.0), 5.0, 2.0),
		StoneWall.Face.new(Vector3(12.0, ground, -2.3), Vector3(1.0, 0.0, 0.0), Vector3(0.0, 0.0, 1.0), 2.2, 2.0),
		StoneWall.Face.new(Vector3(12.0, ground, 2.3), Vector3(1.0, 0.0, 0.0), Vector3(0.0, 0.0, -1.0), 2.2, 2.0),
	]
	var walls: MeshInstance3D = MeshInstance3D.new()
	walls.name = "ShelterWalls"
	walls.mesh = StoneWall.build(faces, 7)
	walls.material_override = SurfaceMaterials.layer_material(SurfaceMaterials.Layer.STONE, Color(0.56, 0.54, 0.50, 1.0), true)
	add_child(walls)
	var shelter: Node3D = Node3D.new()
	shelter.name = "Shelter"
	add_child(shelter)
	_add_collision_box(shelter, "Back", Vector3(14.2, ground + 1.0, 0.0), Vector3(0.45, 2.0, 5.0))
	_add_collision_box(shelter, "North", Vector3(13.1, ground + 1.0, -2.3), Vector3(2.2, 2.0, 0.45))
	_add_collision_box(shelter, "South", Vector3(13.1, ground + 1.0, 2.3), Vector3(2.2, 2.0, 0.45))
	# Junta oscura detrás de las piedras: los huecos de la pirca seca no deben
	# dejar ver el cielo ni el interior del refugio.
	var mortar: StandardMaterial3D = StandardMaterial3D.new()
	mortar.albedo_color = Color(0.16, 0.14, 0.12, 1.0)
	mortar.roughness = 1.0
	for wall_data: Array in [
		[Vector3(14.32, ground + 1.0, 0.0), Vector3(0.22, 2.0, 5.0)],
		[Vector3(13.1, ground + 1.0, -2.42), Vector3(2.2, 2.0, 0.22)],
		[Vector3(13.1, ground + 1.0, 2.42), Vector3(2.2, 2.0, 0.22)],
	]:
		var backing: MeshInstance3D = MeshInstance3D.new()
		var backing_box: BoxMesh = BoxMesh.new()
		backing_box.size = wall_data[1]
		backing.mesh = backing_box
		backing.material_override = mortar
		backing.position = wall_data[0]
		shelter.add_child(backing)
	var stone: ShaderMaterial = SurfaceMaterials.layer_material(SurfaceMaterials.Layer.STONE, Color(0.56, 0.54, 0.50, 1.0))
	var roof: MeshInstance3D = MeshInstance3D.new()
	roof.name = "Roof"
	var box: BoxMesh = BoxMesh.new()
	box.size = Vector3(2.9, 0.18, 5.2)
	roof.mesh = box
	roof.material_override = stone
	roof.position = Vector3(13.1, ground + 2.05, 0.0)
	shelter.add_child(roof)
	var wood: ShaderMaterial = SurfaceMaterials.layer_material(SurfaceMaterials.Layer.WOOD, Color(0.36, 0.26, 0.17, 1.0))
	for beam_x: float in [12.25, 14.0]:
		var beam: MeshInstance3D = MeshInstance3D.new()
		var cylinder: CylinderMesh = CylinderMesh.new()
		cylinder.top_radius = 0.07
		cylinder.bottom_radius = 0.08
		cylinder.height = 5.2
		beam.mesh = cylinder
		beam.material_override = wood
		beam.position = Vector3(beam_x, ground + 1.92, 0.0)
		beam.rotation_degrees.x = 90.0
		shelter.add_child(beam)


func _build_vegetation() -> void:
	var vegetation: PasoVegetation = PasoVegetation.new()
	vegetation.name = "Vegetation"
	add_child(vegetation)
	var blocked: Array[Rect2] = [
		Rect2(-10.0, 12.5, 12.0, 10.0),
		Rect2(10.0, -5.0, 8.0, 10.0),
		Rect2(-3.0, 28.0, 6.0, 5.0),
	]
	vegetation.build(_height_at, blocked, ROCK_POSITIONS)
	var wind: LlactaWind = LlactaWind.new()
	wind.name = "Wind"
	wind.materials = vegetation.wind_materials
	add_child(wind)


func _build_bounds() -> void:
	var bounds: Node3D = Node3D.new()
	bounds.name = "Bounds"
	add_child(bounds)
	_add_collision_box(bounds, "North", Vector3(0.0, 6.0, -BOUNDS_HALF_Z), Vector3(BOUNDS_HALF_X * 2.0, 12.0, 1.0))
	_add_collision_box(bounds, "South", Vector3(0.0, 6.0, BOUNDS_HALF_Z), Vector3(BOUNDS_HALF_X * 2.0, 12.0, 1.0))
	_add_collision_box(bounds, "East", Vector3(BOUNDS_HALF_X, 6.0, 0.0), Vector3(1.0, 12.0, BOUNDS_HALF_Z * 2.0))
	_add_collision_box(bounds, "West", Vector3(-BOUNDS_HALF_X, 6.0, 0.0), Vector3(1.0, 12.0, BOUNDS_HALF_Z * 2.0))


func _add_collision_box(parent: Node3D, box_name: String, at: Vector3, size: Vector3) -> StaticBody3D:
	var body: StaticBody3D = StaticBody3D.new()
	body.name = box_name
	body.collision_layer = 1
	body.collision_mask = 0
	body.position = at
	var shape: CollisionShape3D = CollisionShape3D.new()
	var box: BoxShape3D = BoxShape3D.new()
	box.size = size
	shape.shape = box
	body.add_child(shape)
	parent.add_child(body)
	return body


## Cúpula de nubes procedurales, como en la llacta.
func _build_clouds() -> void:
	if not ResourceLoader.exists(CLOUD_SHADER_PATH):
		return
	var shader: Shader = load(CLOUD_SHADER_PATH) as Shader
	if shader == null:
		return
	var material: ShaderMaterial = ShaderMaterial.new()
	material.shader = shader
	var sphere: SphereMesh = SphereMesh.new()
	sphere.radius = CLOUD_DOME_RADIUS
	sphere.height = CLOUD_DOME_RADIUS * 2.0
	sphere.radial_segments = CLOUD_DOME_SEGMENTS
	sphere.rings = CLOUD_DOME_RINGS
	var dome: MeshInstance3D = MeshInstance3D.new()
	dome.name = "CloudDome"
	dome.mesh = sphere
	dome.material_override = material
	dome.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	dome.gi_mode = GeometryInstance3D.GI_MODE_DISABLED
	add_child(dome)


func _setup_audio() -> void:
	CampaignAudio.setup_footsteps(player)
	var wind: AudioStreamPlayer = CampaignAudio.add_wind(self, -18.0)
	var wind_node: LlactaWind = get_node_or_null("Wind") as LlactaWind
	if wind_node != null and wind != null:
		wind_node.ambience = wind
		wind_node.ambience_base_db = wind.volume_db
	CampaignAudio.add_loop_3d(
		self, "StreamAmbience", CampaignAudio.WATER_PATH,
		Vector3(STREAM_X, WATER_LEVEL + 0.3, 0.0), -20.0, 4.0, 25.0)
	CampaignAudio.add_loop_3d(
		self, "FireAmbience", CampaignAudio.FIRE_PATH,
		Vector3(CAMP_POSITION.x, _height_at(CAMP_POSITION.x, CAMP_POSITION.z) + 0.5, CAMP_POSITION.z),
		-14.0, 3.0, 18.0)
	_battle_drum = CampaignAudio.add_loop(self, "BattleDrum", CampaignAudio.DRUM_PATH, -16.0, false)


func _start_drum() -> void:
	if _battle_drum != null and not _battle_drum.playing:
		_battle_drum.play()


func _stop_drum() -> void:
	if _battle_drum != null and _battle_drum.playing:
		_battle_drum.stop()


## E, Intro o R continúan desde la tarjeta de fin. E es la tecla de avance del
## juego; R se conserva como atajo.
static func _advance_requested(event: InputEvent) -> bool:
	if event.is_action_pressed("interact"):
		return true
	if not (event is InputEventKey):
		return false
	var key: InputEventKey = event as InputEventKey
	if not key.pressed or key.echo:
		return false
	return key.keycode == KEY_R or key.keycode == KEY_ENTER or key.keycode == KEY_KP_ENTER


## Solo R reintenta tras caer: E podría confundirse con una interacción.
static func _retry_requested(event: InputEvent) -> bool:
	if not (event is InputEventKey):
		return false
	var key: InputEventKey = event as InputEventKey
	return key.pressed and not key.echo and key.keycode == KEY_R


func _bind_environment() -> void:
	var controller: EnvironmentQualityController = get_node_or_null("EnvironmentQualityController") as EnvironmentQualityController
	if controller != null:
		controller.bind($WorldEnvironment as WorldEnvironment, $Sun as DirectionalLight3D)