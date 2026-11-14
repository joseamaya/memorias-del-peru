extends Node3D
## Acto III en gris: el Cusco de 1438, el reclutamiento y la defensa.
##
## La ciudad es un bloqueo: plaza, santuario, casas y muro. El jugador recluta a
## tres grupos según lo que hizo en el acto II (banderas de `CampaignState`),
## habla con Cusi Yupanqui y sostiene la defensa. La victoria es fija; el
## epílogo cambia con las decisiones anteriores.

const CITY_SIZE: float = 150.0
const WALL_RADIUS: float = 30.0
const BOUNDARY_RADIUS: float = 70.0
const GRASS_COLOR: Color = Color(0.33, 0.36, 0.24, 1.0)
const ROCK_COLOR: Color = Color(0.46, 0.44, 0.40, 1.0)
const DIRT_COLOR: Color = Color(0.47, 0.38, 0.26, 1.0)
const STONE_TINT: Color = Color(0.52, 0.50, 0.46, 1.0)
const THATCH_TINT: Color = Color(0.50, 0.40, 0.22, 1.0)
const SOIL_TINT: Color = Color(0.34, 0.27, 0.19, 1.0)
const MODEL_DIR: String = "res://campaigns/01_pachacutec/assets/models/"
const MODEL_HOUSES: Array[String] = ["pch_house_a.glb", "pch_house_b.glb", "pch_house_c.glb"]
const MODEL_PROP_JAR: String = "pch_prop_jar.glb"
const MODEL_PROP_FIREWOOD: String = "pch_prop_firewood.glb"
const HOUSE_DEPTHS: Array[float] = [5.0, 4.6, 4.0]
const HOUSE_LEFT_PROP_X: Array[float] = [-2.1, -2.4, -1.7]
const HOUSE_YAW_JITTER: Array[float] = [7.0, -11.0, 4.0, -6.0, 10.0, -8.0, 5.0, -4.0]
## Catorce viviendas alrededor de la plaza, fuera de los caminos y del santuario.
const HOUSE_POSITIONS: Array[Vector3] = [
	Vector3(-24.0, 0.0, -18.0),
	Vector3(-26.0, 0.0, -8.0),
	Vector3(-24.0, 0.0, 4.0),
	Vector3(-25.0, 0.0, 14.0),
	Vector3(-18.0, 0.0, 22.0),
	Vector3(24.0, 0.0, -18.0),
	Vector3(26.0, 0.0, -8.0),
	Vector3(24.0, 0.0, 4.0),
	Vector3(25.0, 0.0, 14.0),
	Vector3(18.0, 0.0, 22.0),
	Vector3(-12.0, 0.0, -24.0),
	Vector3(12.0, 0.0, -24.0),
	Vector3(-10.0, 0.0, 26.0),
	Vector3(10.0, 0.0, 26.0),
]
## Refugiados y vecinos que llenan la plaza; no interactúan, solo dan escala.
const CROWD_POSITIONS: Array[Vector3] = [
	Vector3(-18.0, 0.0, 10.0),
	Vector3(-19.0, 0.0, 4.0),
	Vector3(-18.0, 0.0, -4.0),
	Vector3(18.0, 0.0, 10.0),
	Vector3(19.0, 0.0, 4.0),
	Vector3(18.0, 0.0, -4.0),
	Vector3(-9.0, 0.0, 16.0),
	Vector3(9.0, 0.0, 16.0),
	Vector3(-13.0, 0.0, -15.0),
	Vector3(13.0, 0.0, -15.0),
]
const CROWD_ROLES: Array[StringName] = [
	&"villager", &"weaver", &"farmer", &"villager", &"messenger",
	&"villager", &"farmer", &"weaver", &"villager", &"messenger",
]
const CROWD_VARIANTS: Array[int] = [0, 0, 0, 1, 0, 2, 1, 1, 2, 2]
## Destinos de la multitud cuando empieza la defensa: junto a las casas, fuera
## de la plaza y de la línea de choque.
const CROWD_SAFE_POSITIONS: Array[Vector3] = [
	Vector3(-21.5, 0.0, 18.0),
	Vector3(-21.5, 0.0, 0.0),
	Vector3(-21.5, 0.0, -10.0),
	Vector3(21.5, 0.0, 18.0),
	Vector3(21.5, 0.0, 0.0),
	Vector3(21.5, 0.0, -10.0),
	Vector3(-12.0, 0.0, 20.0),
	Vector3(12.0, 0.0, 20.0),
	Vector3(-15.0, 0.0, -20.0),
	Vector3(15.0, 0.0, -20.0),
]
const CROWD_RETREAT_SPEED: float = 2.2
## Capa propia para que solo el jugador choque con la multitud; los chancas
## (capa 1) la atraviesan y no se quedan atascados.
const CROWD_COLLISION_LAYER: int = 16
const CAMP_SCENE: String = "res://campaigns/01_pachacutec/scenes/objects/camp_point.tscn"
const RECRUIT_POSITIONS: Array[Vector3] = [
	Vector3(-15.0, 0.9, 0.0),
	Vector3(15.0, 0.9, 0.0),
	Vector3(0.0, 0.9, 12.0),
]
const RECRUIT_PROMPTS: Array[StringName] = [
	&"PCH_CIUDAD_TALK_AYLLUS",
	&"PCH_CIUDAD_TALK_CURACA",
	&"PCH_CIUDAD_TALK_YOUTH",
]
const RECRUIT_SPEAKERS: Array[StringName] = [
	&"PCH_NPC_AYLLUS",
	&"PCH_NPC_CURACA_VECINO",
	&"PCH_NPC_YOUTH",
]
const RECRUIT_INTROS: Array[StringName] = [
	&"PCH_CIUDAD_AYLLUS_INTRO",
	&"PCH_CIUDAD_CURACA_INTRO",
	&"PCH_CIUDAD_YOUTH_INTRO",
]
const CUSI_POSITION: Vector3 = Vector3(0.0, 0.9, -12.0)
## El viejo que cuenta la leyenda de los pururaucas, junto al santuario.
const VESPERA_POSITION: Vector3 = Vector3(5.0, 0.9, -8.0)
const DEFENSE_POSITIONS: Array[Vector3] = [
	Vector3(0.0, 0.0, -4.0),
	Vector3(6.0, 0.0, -2.0),
	Vector3(-6.0, 0.0, -2.0),
	Vector3(0.0, 0.0, 4.0),
]
const RECRUIT_ROLES: Array[StringName] = [&"villager", &"curaca", &"villager"]
const ALLY_POSITIONS: Array[Vector3] = [
	Vector3(-4.0, 0.0, 2.0),
	Vector3(4.0, 0.0, 2.0),
	Vector3(0.0, 0.0, 5.0),
]

## Figura de multitud con su destino de retirada.
class CrowdMember:
	var visual: MannequinVisual
	var safe_position: Vector3
	var retreating: bool = false

	func _init(figure: MannequinVisual, safe: Vector3) -> void:
		visual = figure
		safe_position = safe


@onready var player: PlayerFPS = $PlayerFPS
@onready var hud: PlayerHud = $UILayer/HUD
@onready var status_label: Label = $UILayer/StatusLabel
@onready var hint_label: Label = $UILayer/HintLabel
@onready var spawn: Marker3D = $PlayerSpawn

var character: CharacterState = null
var player_combatant: Combatant = null
var inventory: Inventory = null
var dialogue: DialogueRunner = null
var journal: Journal = null

var _enemies: Array[AmbushEnemy] = []
var _attack_ray: RayCast3D = null
var _defense_active: bool = false
var _defense_requested: bool = false
var _completed: bool = false
var _dead: bool = false
var _blocking: bool = false
var _battle_drum: AudioStreamPlayer = null
var _dialogue_speaker: StringName = &""
var _dialogue_text: StringName = &""
var _ally_visuals: Dictionary[int, bool] = {}
var _crowd: Array[CrowdMember] = []
var _crowd_retreating: bool = false


func _ready() -> void:
	player.global_position = spawn.global_position
	# La multitud usa una capa que solo el jugador consulta: evita atravesarla
	# sin convertirla en un obstáculo para los chancas.
	player.collision_mask = player.collision_mask | CROWD_COLLISION_LAYER
	hud.bind(player, player.stamina)
	_build_city()
	_setup_player_combat()
	_setup_inventory_and_dialogue()
	_setup_journal()
	_setup_recruitment()
	_setup_cusi()
	_setup_vespera()
	_restore_allies()
	_setup_audio()
	_bind_environment()
	hint_label.text = ""
	hud.show_subtitle(tr("PCH_CIUDAD_ARRIVAL"), 0.0)
	_update_status()


## Indica si la defensa está en curso. Lo consultan los enemigos reutilizados.
func is_ambush_active() -> bool:
	return _defense_active and not _completed and not _dead


## Indica si la campaña terminó.
func is_completed() -> bool:
	return _completed


## Indica si el jugador cayó.
func is_dead() -> bool:
	return _dead


## Número de enemigos en pie.
func alive_enemies() -> int:
	var count: int = 0
	for enemy: AmbushEnemy in _enemies:
		if is_instance_valid(enemy) and enemy.is_alive():
			count += 1
	return count


## Número de aliados reclutados.
func ally_count() -> int:
	var count: int = 0
	for index: int in range(3):
		if CampaignState.has_flag(_ally_key(index)):
			count += 1
	return count


## Aplica daño al jugador; el escudo reduce una parte y consume aliento.
func apply_player_damage(amount: float) -> void:
	if _dead or _completed or character == null:
		return
	var applied: float = amount
	if _blocking:
		applied *= 0.3
		if player.stamina != null:
			player.stamina.consume(5.0)
	character.damage(applied)
	if not character.is_alive():
		_dead = true
		hint_label.text = tr("PCH_CIUDAD_DEAD")
	_update_status()


## Un enemigo se resolvió; actualiza la cuenta.
func on_enemy_resolved() -> void:
	_update_status()


func _physics_process(_delta: float) -> void:
	if not _defense_active or _completed or _dead:
		return
	if alive_enemies() == 0:
		_finish_defense()
	_update_status()


func _process(delta: float) -> void:
	if _crowd_retreating:
		_update_crowd(delta)


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("journal"):
		if hud == null or journal == null or _completed or _dead or _defense_active:
			return
		if hud.is_dialogue_open():
			return
		if hud.is_journal_open():
			hud.hide_journal()
			player.process_mode = Node.PROCESS_MODE_INHERIT
		else:
			hud.show_journal(journal)
			player.process_mode = Node.PROCESS_MODE_DISABLED
		get_viewport().set_input_as_handled()
		return
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
	if event is InputEventKey:
		var key: InputEventKey = event as InputEventKey
		if key.pressed and not key.echo and key.keycode == KEY_R:
			if _completed:
				get_tree().change_scene_to_file("res://core/ui/title_screen.tscn")
			elif _dead:
				get_tree().reload_current_scene()
			return
		if key.pressed and not key.echo and key.keycode == KEY_ESCAPE and _completed:
			var manager: Node = get_node_or_null("/root/GameManager")
			if manager != null:
				manager.call("request_quit")


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
	_attack_ray.force_raycast_update()
	if not _attack_ray.is_colliding():
		return
	var enemy: AmbushEnemy = _attack_ray.get_collider() as AmbushEnemy
	if enemy != null:
		CampaignAudio.play_sfx(CampaignAudio.IMPACT_PATH, -6.0)
		enemy.take_hit(damage)
	_update_status()


func _setup_recruitment() -> void:
	for index: int in range(RECRUIT_POSITIONS.size()):
		var instance: Node = (load(CAMP_SCENE) as PackedScene).instantiate()
		var point: CampPoint = instance as CampPoint
		var body: Node3D = instance as Node3D
		if point == null or body == null:
			instance.free()
			continue
		point.name = "Recruit%d" % index
		point.prompt_key = RECRUIT_PROMPTS[index]
		body.position = RECRUIT_POSITIONS[index]
		add_child(point)
		point.requested.connect(_on_recruit_requested.bind(index))
		_add_visual_npc(Vector3(RECRUIT_POSITIONS[index].x, 0.0, RECRUIT_POSITIONS[index].z), RECRUIT_ROLES[index], index)


func _setup_cusi() -> void:
	var instance: Node = (load(CAMP_SCENE) as PackedScene).instantiate()
	var point: CampPoint = instance as CampPoint
	var body: Node3D = instance as Node3D
	if point == null or body == null:
		instance.free()
		return
	point.name = "CusiPoint"
	point.prompt_key = &"PCH_CIUDAD_TALK_CUSI"
	body.position = CUSI_POSITION
	add_child(point)
	point.requested.connect(_on_cusi_requested)
	_add_visual_npc(Vector3(CUSI_POSITION.x, 0.0, CUSI_POSITION.z), &"curaca", 0)


## Diario del acto III: guarda la leyenda de los pururaucas como Memoria.
func _setup_journal() -> void:
	journal = Journal.new()
	journal.name = "Journal"
	player.add_child(journal)
	hud.journal_closed.connect(_on_journal_closed)


## Víspera opcional: un viejo cuenta la leyenda antes de la defensa.
func _setup_vespera() -> void:
	var instance: Node = (load(CAMP_SCENE) as PackedScene).instantiate()
	var point: CampPoint = instance as CampPoint
	var body: Node3D = instance as Node3D
	if point == null or body == null:
		instance.free()
		return
	point.name = "VesperaPoint"
	point.prompt_key = &"PCH_CIUDAD_TALK_VESPERA"
	body.position = VESPERA_POSITION
	add_child(point)
	point.requested.connect(_on_vespera_requested)
	_add_visual_npc(Vector3(VESPERA_POSITION.x, 0.0, VESPERA_POSITION.z), &"villager", 2)


func _on_vespera_requested() -> void:
	if _defense_active or _completed or _dead or dialogue == null:
		return
	if dialogue.is_active():
		return
	if CampaignState.has_flag(&"mem_pururaucas"):
		hud.show_subtitle(tr("PCH_VESPERA_AGAIN"), 0.0)
		return
	var graph: DialogueGraph = _build_vespera_dialogue()
	if dialogue.start(graph):
		player.process_mode = Node.PROCESS_MODE_DISABLED


## La leyenda se cuenta como creencia: el texto dice «dicen» y «así lo
## cuentan», y ninguna piedra se transforma ni cambia la defensa (PCH-031).
func _build_vespera_dialogue() -> DialogueGraph:
	var graph: DialogueGraph = DialogueGraph.new()
	graph.entry_id = &"start"
	var start: DialogueNode = DialogueNode.new()
	start.id = &"start"
	start.speaker_key = &"PCH_NPC_ELDER"
	start.text_key = &"PCH_VESPERA_INTRO"
	start.next_id = &"end"
	var listen: DialogueChoice = DialogueChoice.new()
	listen.text_key = &"PCH_VESPERA_LISTEN"
	listen.next_id = &"tale"
	var leave: DialogueChoice = DialogueChoice.new()
	leave.text_key = &"PCH_DLG_LEAVE"
	leave.next_id = &"end"
	var choices: Array[DialogueChoice] = [listen, leave]
	start.choices = choices
	var tale: DialogueNode = DialogueNode.new()
	tale.id = &"tale"
	tale.speaker_key = &"PCH_NPC_ELDER"
	tale.text_key = &"PCH_VESPERA_TALE"
	tale.next_id = &"close"
	var effect: DialogueEffect = DialogueEffect.new()
	effect.kind = DialogueEffect.Kind.SET_FLAG
	effect.key = &"mem_pururaucas"
	effect.amount = 1
	var effects: Array[DialogueEffect] = [effect]
	tale.effects = effects
	var close: DialogueNode = DialogueNode.new()
	close.id = &"close"
	close.speaker_key = &"PCH_NPC_ELDER"
	close.text_key = &"PCH_VESPERA_CLOSE"
	close.next_id = &"end"
	var nodes: Array[DialogueNode] = [start, tale, close]
	graph.nodes = nodes
	return graph


func _on_journal_closed() -> void:
	player.process_mode = Node.PROCESS_MODE_INHERIT


func _unlock_memory(
	entry_id: StringName,
	title_key: StringName,
	body_key: StringName,
	badge: StringName,
	source_key: StringName
) -> void:
	if journal == null:
		return
	if journal.add_memory(entry_id, title_key, body_key, badge, source_key):
		if hud != null:
			hud.show_hint(tr("UI_JOURNAL_UPDATED"), 3.0)


func _on_recruit_requested(index: int) -> void:
	if _defense_active or _completed or _dead or dialogue == null:
		return
	if dialogue.is_active():
		return
	if CampaignState.has_flag(_ally_key(index)):
		hud.show_subtitle(tr("PCH_CIUDAD_ALREADY"), 0.0)
		return
	var joins: bool = _recruit_joins(index)
	var graph: DialogueGraph = _build_recruit_dialogue(index, joins)
	if dialogue.start(graph):
		player.process_mode = Node.PROCESS_MODE_DISABLED


func _on_cusi_requested() -> void:
	if _defense_active or _completed or _dead or dialogue == null:
		return
	if dialogue.is_active():
		return
	var graph: DialogueGraph = _build_cusi_dialogue()
	if dialogue.start(graph):
		player.process_mode = Node.PROCESS_MODE_DISABLED


func _recruit_joins(index: int) -> bool:
	match index:
		0:
			return CampaignState.has_flag(&"maiz_guardado")
		1:
			return CampaignState.has_flag(&"herido_salvado") or CampaignState.has_flag(&"descanso")
		2:
			return CampaignState.has_flag(&"coca_compartida") or CampaignState.has_flag(&"descanso")
	return false


func _build_recruit_dialogue(index: int, joins: bool) -> DialogueGraph:
	var graph: DialogueGraph = DialogueGraph.new()
	graph.entry_id = &"start"
	var start: DialogueNode = DialogueNode.new()
	start.id = &"start"
	start.speaker_key = RECRUIT_SPEAKERS[index]
	start.text_key = RECRUIT_INTROS[index]
	start.next_id = &"end"
	var ask: DialogueChoice = DialogueChoice.new()
	ask.text_key = &"PCH_CIUDAD_RECRUIT_ASK"
	ask.next_id = &"answer"
	var leave: DialogueChoice = DialogueChoice.new()
	leave.text_key = &"PCH_DLG_LEAVE"
	leave.next_id = &"end"
	var choices: Array[DialogueChoice] = [ask, leave]
	start.choices = choices
	var answer: DialogueNode = DialogueNode.new()
	answer.id = &"answer"
	answer.speaker_key = RECRUIT_SPEAKERS[index]
	answer.text_key = &"PCH_CIUDAD_RECRUIT_JOIN" if joins else &"PCH_CIUDAD_RECRUIT_REFUSE"
	answer.next_id = &"end"
	if joins:
		var effect: DialogueEffect = DialogueEffect.new()
		effect.kind = DialogueEffect.Kind.SET_FLAG
		effect.key = _ally_key(index)
		effect.amount = 1
		var effects: Array[DialogueEffect] = [effect]
		answer.effects = effects
	var nodes: Array[DialogueNode] = [start, answer]
	graph.nodes = nodes
	return graph


func _build_cusi_dialogue() -> DialogueGraph:
	var graph: DialogueGraph = DialogueGraph.new()
	graph.entry_id = &"start"
	var start: DialogueNode = DialogueNode.new()
	start.id = &"start"
	start.speaker_key = &"PCH_NPC_CUSI"
	start.text_key = &"PCH_CIUDAD_CUSI_INTRO"
	start.next_id = &"end"
	var start_choice: DialogueChoice = DialogueChoice.new()
	start_choice.text_key = &"PCH_CIUDAD_CUSI_READY"
	start_choice.next_id = &"accept"
	var wait: DialogueChoice = DialogueChoice.new()
	wait.text_key = &"PCH_CIUDAD_CUSI_WAIT"
	wait.next_id = &"end"
	var choices: Array[DialogueChoice] = [start_choice, wait]
	start.choices = choices
	var accept: DialogueNode = DialogueNode.new()
	accept.id = &"accept"
	accept.speaker_key = &"PCH_NPC_CUSI"
	accept.text_key = &"PCH_CIUDAD_CUSI_ACCEPT"
	accept.next_id = &"end"
	var effect: DialogueEffect = DialogueEffect.new()
	effect.kind = DialogueEffect.Kind.SET_FLAG
	effect.key = &"defensa_iniciada"
	effect.amount = 1
	var effects: Array[DialogueEffect] = [effect]
	accept.effects = effects
	var nodes: Array[DialogueNode] = [start, accept]
	graph.nodes = nodes
	return graph


func _start_defense() -> void:
	if _defense_active or _completed or _dead:
		return
	_defense_active = true
	_defense_requested = false
	_start_drum()
	_retreat_crowd()
	var count: int = maxi(1, 4 - ally_count())
	for index: int in range(count):
		var enemy: AmbushEnemy = AmbushEnemy.new()
		enemy.name = "Defender%d" % (index + 1)
		enemy.position = DEFENSE_POSITIONS[index]
		add_child(enemy)
		enemy.setup(player, self)
		_enemies.append(enemy)
	hud.show_subtitle(tr("PCH_CIUDAD_DEFENSE"), 0.0)
	_update_status()


## La multitud deja la plaza cuando empieza la defensa y se refugia junto a las
## casas. No participa en el combate; solo da vida al cambio de la ciudad.
func _retreat_crowd() -> void:
	if _crowd.is_empty():
		return
	_crowd_retreating = true
	for member: CrowdMember in _crowd:
		member.retreating = true
		member.visual.play(&"Walk", 1.15)


func _update_crowd(delta: float) -> void:
	var remaining: bool = false
	for member: CrowdMember in _crowd:
		if not member.retreating:
			continue
		remaining = true
		var target: Vector3 = Vector3(
			member.safe_position.x,
			member.visual.position.y,
			member.safe_position.z)
		var distance: float = member.visual.position.distance_to(target)
		if distance <= 0.2:
			member.retreating = false
			member.visual.play(&"Idle")
			var center: Vector3 = Vector3(0.0, member.visual.position.y, 0.0)
			if member.visual.position.distance_to(center) > 0.1:
				member.visual.look_at(center, Vector3.UP)
			continue
		member.visual.position = member.visual.position.move_toward(target, CROWD_RETREAT_SPEED * delta)
		var flat_target: Vector3 = Vector3(target.x, member.visual.position.y, target.z)
		if member.visual.position.distance_to(flat_target) > 0.1:
			member.visual.look_at(flat_target, Vector3.UP)
	if not remaining:
		_crowd_retreating = false


func _finish_defense() -> void:
	if _completed:
		return
	_completed = true
	_defense_active = false
	_stop_drum()
	hud.show_subtitle(tr("PCH_CIUDAD_COUNTER"), 0.0)
	var epilogue: String = tr("PCH_CIUDAD_EPILOGUE")
	if CampaignState.has_flag(&"herido_salvado"):
		epilogue += " " + tr("PCH_CIUDAD_EPILOGUE_WOUNDED")
	if CampaignState.has_flag(&"maiz_guardado"):
		epilogue += " " + tr("PCH_CIUDAD_EPILOGUE_MAIZE")
	if CampaignState.has_flag(&"scout_spared"):
		epilogue += " " + tr("PCH_CIUDAD_EPILOGUE_SPARED")
	hud.show_subtitle(epilogue, 0.0)
	hud.show_end_card(tr("PCH_CIUDAD_END_TITLE"), tr("PCH_CIUDAD_END_HINT"))


## Aplica el perfil gráfico al cielo y al sol del Cusco, como en la llacta y el
## paso: SSAO en Medio, niebla volumétrica en Alto/Ultra y distancia de sombra.
func _bind_environment() -> void:
	var controller: EnvironmentQualityController = get_node_or_null("EnvironmentQualityController") as EnvironmentQualityController
	if controller != null:
		controller.bind($WorldEnvironment as WorldEnvironment, $Sun as DirectionalLight3D)


func _setup_audio() -> void:
	CampaignAudio.setup_footsteps(player)
	CampaignAudio.add_wind(self, -20.0)
	CampaignAudio.add_loop_3d(
		self, "PlazaMurmur", CampaignAudio.MURMUR_PATH,
		Vector3(0.0, 1.5, -2.0), -18.0, 12.0, 70.0)
	_battle_drum = CampaignAudio.add_loop(self, "BattleDrum", CampaignAudio.DRUM_PATH, -15.0, false)


func _start_drum() -> void:
	if _battle_drum != null and not _battle_drum.playing:
		_battle_drum.play()


func _stop_drum() -> void:
	if _battle_drum != null and _battle_drum.playing:
		_battle_drum.stop()


func _update_status() -> void:
	if status_label == null or character == null:
		return
	status_label.text = tr("PCH_CIUDAD_STATUS") % [int(character.get_health()), ally_count(), alive_enemies()]


func _restore_allies() -> void:
	for index: int in range(3):
		if CampaignState.has_flag(_ally_key(index)):
			_add_ally_visual(index)


func _add_visual_npc(at: Vector3, role: StringName, variant: int) -> void:
	var visual: MannequinVisual = MannequinVisual.new()
	visual.name = "Visual"
	visual.skin = true
	visual.tint = DressedMannequin.SKIN_COLOR
	visual.position = at
	add_child(visual)
	var outfit: DressedMannequin = DressedMannequin.new()
	outfit.name = "Outfit"
	outfit.role = role
	outfit.variant = variant
	visual.add_child(outfit)


func _add_ally_visual(index: int) -> void:
	if _ally_visuals.has(index):
		return
	_ally_visuals[index] = true
	var visual: MannequinVisual = MannequinVisual.new()
	visual.name = "Ally%d" % index
	visual.skin = true
	visual.tint = DressedMannequin.SKIN_COLOR
	visual.position = ALLY_POSITIONS[index]
	add_child(visual)
	var outfit: DressedMannequin = DressedMannequin.new()
	outfit.name = "Outfit"
	outfit.role = &"villager"
	outfit.variant = index
	visual.add_child(outfit)


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
	player.process_mode = Node.PROCESS_MODE_INHERIT
	if _defense_requested:
		_start_defense()


func _on_dialogue_flag(key: StringName, value: int) -> void:
	CampaignState.set_flag(key, value)
	if key == &"defensa_iniciada" and value != 0:
		_defense_requested = true
		return
	if key == &"mem_pururaucas" and value != 0:
		_unlock_memory(&"mem_pururaucas", &"PCH_ST_PURURAUCAS_TITLE", &"PCH_ST_PURURAUCAS_BODY", &"N", &"PCH-031")
		return
	if value == 0:
		return
	for index: int in range(3):
		if key == _ally_key(index):
			_add_ally_visual(index)
	_update_status()


func _setup_player_combat() -> void:
	character = CharacterState.new()
	character.name = "CharacterState"
	player.add_child(character)
	var sling: CombatWeapon = CombatWeapon.new()
	sling.kind = CombatWeapon.Kind.SLING
	sling.damage_min = 18.0
	sling.damage_max = 32.0
	sling.range_min = 3.0
	sling.range_max = 28.0
	sling.charge_full_seconds = 1.2
	sling.stamina_cost = 10.0
	sling.cooldown_seconds = 0.8
	player_combatant = Combatant.new()
	player_combatant.name = "PlayerCombatant"
	player_combatant.character = character
	player_combatant.weapon = sling
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


## Ciudad del Cusco de 1438: terreno, plaza de tierra, santuario, viviendas,
## muro de pirca, terrazas y multitud. Sustituye el bloqueo gris de la Fase 7
## sin cambiar la lógica de reclutamiento ni de defensa.
func _build_city() -> void:
	_build_terrain()
	_build_plaza_areas()
	_build_sanctuary()
	_build_houses()
	_build_walls()
	_build_gate()
	_build_wall_caps()
	_build_plaza_furniture()
	_build_sanctuary_props()
	_build_vegetation()
	_build_terraces()
	_build_crowd()


func _build_terrain() -> void:
	var terrain: Node3D = Node3D.new()
	terrain.name = "Terrain"
	add_child(terrain)
	var plane: PlaneMesh = PlaneMesh.new()
	plane.size = Vector2(CITY_SIZE, CITY_SIZE)
	var mesh_instance: MeshInstance3D = MeshInstance3D.new()
	mesh_instance.name = "TerrainMesh"
	mesh_instance.mesh = plane
	mesh_instance.material_override = SurfaceMaterials.terrain_material(GRASS_COLOR, ROCK_COLOR, DIRT_COLOR)
	# El suelo es plano: recibe las sombras de casas y figuras, pero no necesita
	# proyectar la suya sobre sí mismo.
	mesh_instance.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	terrain.add_child(mesh_instance)
	_add_collision_box(terrain, "TerrainBody", Vector3(0.0, -0.5, 0.0), Vector3(CITY_SIZE, 1.0, CITY_SIZE))


## La plaza y los caminos se pintan como tierra apisonada sobre el terreno; las
## cajas quedan ocultas y solo aportan el rectángulo.
func _build_plaza_areas() -> void:
	var areas: Array[MeshInstance3D] = [
		_add_overlay_box("PlazaArea", Vector3(0.0, 0.05, 0.0), Vector3(40.0, 0.1, 40.0)),
		_add_overlay_box("PathSouth", Vector3(0.0, 0.05, 20.0), Vector3(8.0, 0.1, 20.0)),
		_add_overlay_box("PathNorth", Vector3(0.0, 0.05, -20.0), Vector3(8.0, 0.1, 20.0)),
		_add_overlay_box("PathEast", Vector3(20.0, 0.05, 0.0), Vector3(20.0, 0.1, 8.0)),
		_add_overlay_box("PathWest", Vector3(-20.0, 0.05, 0.0), Vector3(20.0, 0.1, 8.0)),
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


## Santuario modesto al sol: tres gradas de piedra y una capilla de ichu. No es
## la ciudad monumental posterior a Pachacútec (PCH-022).
func _build_sanctuary() -> void:
	var sanctuary: Node3D = Node3D.new()
	sanctuary.name = "Sanctuary"
	add_child(sanctuary)
	var stone: ShaderMaterial = SurfaceMaterials.layer_material(SurfaceMaterials.Layer.STONE, STONE_TINT)
	var thatch: ShaderMaterial = SurfaceMaterials.layer_material(SurfaceMaterials.Layer.THATCH, THATCH_TINT)
	_add_block(sanctuary, "Base", Vector3(0.0, 0.3, -18.0), Vector3(9.0, 0.6, 9.0), stone, true)
	_add_block(sanctuary, "StepMiddle", Vector3(0.0, 0.9, -18.0), Vector3(7.0, 0.6, 7.0), stone, true)
	_add_block(sanctuary, "StepTop", Vector3(0.0, 1.5, -18.0), Vector3(5.0, 0.6, 5.0), stone, true)
	_add_block(sanctuary, "Shrine", Vector3(0.0, 2.4, -18.0), Vector3(3.0, 1.2, 3.0), stone, true)
	for side: float in [-1.0, 1.0]:
		_add_block(sanctuary, "Pillar%s" % ("West" if side < 0.0 else "East"),
			Vector3(2.2 * side, 2.4, -18.0), Vector3(0.45, 2.0, 0.45), stone, true)
	var roof: MeshInstance3D = MeshInstance3D.new()
	roof.name = "Roof"
	roof.position = Vector3(0.0, 3.6, -18.0)
	var prism: PrismMesh = PrismMesh.new()
	prism.size = Vector3(4.6, 1.4, 4.6)
	roof.mesh = prism
	roof.material_override = thatch
	sanctuary.add_child(roof)
	# Puerta oscura en la cara sur: el santuario se lee como recinto, no como
	# un pedestal macizo.
	var shadow: StandardMaterial3D = StandardMaterial3D.new()
	shadow.albedo_color = Color(0.05, 0.04, 0.03, 1.0)
	shadow.roughness = 1.0
	_add_block(sanctuary, "Doorway", Vector3(0.0, 2.5, -16.46), Vector3(1.2, 1.6, 0.06), shadow, false)


## Catorce viviendas de piedra y ichu con los modelos definitivos, sus props y
## colisión. El modelo oculta el bloqueo y conserva la colisión si la trae.
func _build_houses() -> void:
	var houses: Node3D = Node3D.new()
	houses.name = "Houses"
	add_child(houses)
	var stone: ShaderMaterial = SurfaceMaterials.layer_material(SurfaceMaterials.Layer.STONE, STONE_TINT)
	var thatch: ShaderMaterial = SurfaceMaterials.layer_material(SurfaceMaterials.Layer.THATCH, THATCH_TINT)
	for index: int in range(HOUSE_POSITIONS.size()):
		_add_house(houses, index, HOUSE_POSITIONS[index], stone, thatch)


func _add_house(parent: Node3D, index: int, at: Vector3, stone: Material, thatch: Material) -> void:
	var root: Node3D = Node3D.new()
	root.name = "House%02d" % (index + 1)
	root.position = at
	parent.add_child(root)
	root.look_at(Vector3(0.0, at.y, 0.0), Vector3.UP)
	root.rotate_y(deg_to_rad(HOUSE_YAW_JITTER[index % HOUSE_YAW_JITTER.size()]))
	var base: Node3D = _add_block(root, "Base", Vector3(0.0, 1.25, 0.0), Vector3(6.0, 2.5, 5.0), stone, true)
	var roof: MeshInstance3D = MeshInstance3D.new()
	roof.name = "Roof"
	roof.position = Vector3(0.0, 3.25, 0.0)
	var prism: PrismMesh = PrismMesh.new()
	prism.size = Vector3(6.6, 1.5, 5.6)
	roof.mesh = prism
	roof.material_override = thatch
	root.add_child(roof)
	root.add_to_group("houses")
	var blockout: Array[Node3D] = [roof]
	var collisions: Array[Node] = []
	for child: Node in base.get_children():
		if child is MeshInstance3D:
			blockout.append(child as MeshInstance3D)
		elif child is CollisionShape3D:
			collisions.append(child)
	var slot: ModelSlot = ModelSlot.new()
	slot.name = "ModelSlot"
	slot.position = Vector3.ZERO
	slot.model_paths = [MODEL_DIR + MODEL_HOUSES[index % MODEL_HOUSES.size()]]
	slot.blockout_nodes = blockout
	slot.blockout_collisions = collisions
	root.add_child(slot)
	SurfaceMaterials.apply_to_model(slot.model)
	_add_house_props(root, index)


## Cántaros y leña delante de la vivienda. El frente mira a −Z local.
func _add_house_props(root: Node3D, index: int) -> void:
	var variant: int = index % MODEL_HOUSES.size()
	var front: float = -HOUSE_DEPTHS[variant] * 0.5 - 0.45
	var left_x: float = HOUSE_LEFT_PROP_X[variant]
	var props: Array[Array] = []
	match index % 3:
		0:
			props = [
				[MODEL_PROP_JAR, Vector3(1.8, 0.0, front)],
				[MODEL_PROP_JAR, Vector3(2.3, 0.0, front - 0.25)],
				[MODEL_PROP_FIREWOOD, Vector3(left_x, 0.0, front)],
			]
		1:
			props = [
				[MODEL_PROP_FIREWOOD, Vector3(2.0, 0.0, front)],
				[MODEL_PROP_JAR, Vector3(left_x - 0.2, 0.0, front)],
			]
		_:
			props = [[MODEL_PROP_JAR, Vector3(2.0, 0.0, front)]]
	for prop_index: int in range(props.size()):
		var entry: Array = props[prop_index]
		var file: String = entry[0]
		var at: Vector3 = entry[1]
		var slot: ModelSlot = ModelSlot.new()
		slot.name = "Prop%d" % prop_index
		slot.position = at
		slot.model_paths = [MODEL_DIR + file]
		root.add_child(slot)
		SurfaceMaterials.apply_to_model(slot.model)
		slot.rotation.y = 0.35 * float((index + prop_index) % 3 - 1)


## Muro de pirca seca con portón al sur. La malla de piedras es una sola llamada
## de dibujo; la colisión va en bloques separados.
func _build_walls() -> void:
	var walls: Node3D = Node3D.new()
	walls.name = "Walls"
	add_child(walls)
	var stone: ShaderMaterial = SurfaceMaterials.layer_material(SurfaceMaterials.Layer.STONE, STONE_TINT, true)
	# Dos caras por muro: la de dentro y la de fuera. El jugador puede salir por
	# el portón y mirar atrás; una pirca de una sola cara desaparecería.
	var faces: Array[StoneWall.Face] = [
		StoneWall.Face.new(Vector3(-WALL_RADIUS, 0.0, -WALL_RADIUS), Vector3(1.0, 0.0, 0.0), Vector3(0.0, 0.0, 1.0), WALL_RADIUS * 2.0, 2.2),
		StoneWall.Face.new(Vector3(-WALL_RADIUS, 0.0, -WALL_RADIUS), Vector3(1.0, 0.0, 0.0), Vector3(0.0, 0.0, -1.0), WALL_RADIUS * 2.0, 2.2),
		StoneWall.Face.new(Vector3(-WALL_RADIUS, 0.0, -WALL_RADIUS), Vector3(0.0, 0.0, 1.0), Vector3(1.0, 0.0, 0.0), WALL_RADIUS * 2.0, 2.2),
		StoneWall.Face.new(Vector3(-WALL_RADIUS, 0.0, -WALL_RADIUS), Vector3(0.0, 0.0, 1.0), Vector3(-1.0, 0.0, 0.0), WALL_RADIUS * 2.0, 2.2),
		StoneWall.Face.new(Vector3(WALL_RADIUS, 0.0, WALL_RADIUS), Vector3(0.0, 0.0, -1.0), Vector3(-1.0, 0.0, 0.0), WALL_RADIUS * 2.0, 2.2),
		StoneWall.Face.new(Vector3(WALL_RADIUS, 0.0, WALL_RADIUS), Vector3(0.0, 0.0, -1.0), Vector3(1.0, 0.0, 0.0), WALL_RADIUS * 2.0, 2.2),
		StoneWall.Face.new(Vector3(-WALL_RADIUS, 0.0, WALL_RADIUS), Vector3(1.0, 0.0, 0.0), Vector3(0.0, 0.0, -1.0), WALL_RADIUS - 6.0, 2.2),
		StoneWall.Face.new(Vector3(-WALL_RADIUS, 0.0, WALL_RADIUS), Vector3(1.0, 0.0, 0.0), Vector3(0.0, 0.0, 1.0), WALL_RADIUS - 6.0, 2.2),
		StoneWall.Face.new(Vector3(6.0, 0.0, WALL_RADIUS), Vector3(1.0, 0.0, 0.0), Vector3(0.0, 0.0, -1.0), WALL_RADIUS - 6.0, 2.2),
		StoneWall.Face.new(Vector3(6.0, 0.0, WALL_RADIUS), Vector3(1.0, 0.0, 0.0), Vector3(0.0, 0.0, 1.0), WALL_RADIUS - 6.0, 2.2),
	]
	var mesh_instance: MeshInstance3D = MeshInstance3D.new()
	mesh_instance.name = "WallMesh"
	mesh_instance.mesh = StoneWall.build(faces, 1438)
	mesh_instance.material_override = stone
	walls.add_child(mesh_instance)
	_add_collision_box(walls, "North", Vector3(0.0, 1.1, -WALL_RADIUS), Vector3(WALL_RADIUS * 2.0, 2.2, 0.6))
	_add_collision_box(walls, "West", Vector3(-WALL_RADIUS, 1.1, 0.0), Vector3(0.6, 2.2, WALL_RADIUS * 2.0))
	_add_collision_box(walls, "East", Vector3(WALL_RADIUS, 1.1, 0.0), Vector3(0.6, 2.2, WALL_RADIUS * 2.0))
	_add_collision_box(walls, "SouthWest", Vector3(-18.0, 1.1, WALL_RADIUS), Vector3(24.0, 2.2, 0.6))
	_add_collision_box(walls, "SouthEast", Vector3(18.0, 1.1, WALL_RADIUS), Vector3(24.0, 2.2, 0.6))
	for side: String in ["North", "South", "West", "East"]:
		var at: Vector3 = Vector3.ZERO
		var size: Vector3 = Vector3.ONE
		match side:
			"North":
				at = Vector3(0.0, 2.0, -BOUNDARY_RADIUS)
				size = Vector3(BOUNDARY_RADIUS * 2.0, 4.0, 1.0)
			"South":
				at = Vector3(0.0, 2.0, BOUNDARY_RADIUS)
				size = Vector3(BOUNDARY_RADIUS * 2.0, 4.0, 1.0)
			"West":
				at = Vector3(-BOUNDARY_RADIUS, 2.0, 0.0)
				size = Vector3(1.0, 4.0, BOUNDARY_RADIUS * 2.0)
			"East":
				at = Vector3(BOUNDARY_RADIUS, 2.0, 0.0)
				size = Vector3(1.0, 4.0, BOUNDARY_RADIUS * 2.0)
		_add_collision_box(walls, "Boundary" + side, at, size)


## Portón sur: dos postes de piedra y un dintel de madera. No hay hoja de
## puerta; el hueco queda abierto para entrar y salir de la ciudad.
func _build_gate() -> void:
	var gate: Node3D = Node3D.new()
	gate.name = "Gate"
	add_child(gate)
	var stone: ShaderMaterial = SurfaceMaterials.layer_material(SurfaceMaterials.Layer.STONE, STONE_TINT)
	var wood: ShaderMaterial = SurfaceMaterials.layer_material(SurfaceMaterials.Layer.WOOD, Color(0.36, 0.26, 0.17, 1.0))
	for side: float in [-1.0, 1.0]:
		_add_block(gate, "Post%s" % ("West" if side < 0.0 else "East"),
			Vector3(6.6 * side, 1.4, WALL_RADIUS), Vector3(0.8, 2.8, 0.8), stone, true)
	_add_block(gate, "Lintel", Vector3(0.0, 2.9, WALL_RADIUS), Vector3(14.0, 0.5, 0.8), wood, false)


## Remate de la muralla: una faja de piedra sobre las dos caras de pirca. Sin
## ella, el muro se ve hueco desde fuera y desde la plaza.
func _build_wall_caps() -> void:
	var caps: Node3D = Node3D.new()
	caps.name = "WallCaps"
	add_child(caps)
	var stone: ShaderMaterial = SurfaceMaterials.layer_material(SurfaceMaterials.Layer.STONE, STONE_TINT)
	_add_block(caps, "NorthCap", Vector3(0.0, 2.25, -WALL_RADIUS),
		Vector3(WALL_RADIUS * 2.0, 0.15, 0.8), stone, false)
	_add_block(caps, "WestCap", Vector3(-WALL_RADIUS, 2.25, 0.0),
		Vector3(0.8, 0.15, WALL_RADIUS * 2.0), stone, false)
	_add_block(caps, "EastCap", Vector3(WALL_RADIUS, 2.25, 0.0),
		Vector3(0.8, 0.15, WALL_RADIUS * 2.0), stone, false)
	_add_block(caps, "SouthWestCap", Vector3(-18.0, 2.25, WALL_RADIUS),
		Vector3(24.0, 0.15, 0.8), stone, false)
	_add_block(caps, "SouthEastCap", Vector3(18.0, 2.25, WALL_RADIUS),
		Vector3(24.0, 0.15, 0.8), stone, false)


## Bancos de piedra y props de plaza: le dan escala y un uso cotidiano al
## espacio abierto, sin añadir edificios nuevos.
func _build_plaza_furniture() -> void:
	var furniture: Node3D = Node3D.new()
	furniture.name = "PlazaFurniture"
	add_child(furniture)
	var stone: ShaderMaterial = SurfaceMaterials.layer_material(SurfaceMaterials.Layer.STONE, STONE_TINT)
	var benches: Array[Vector3] = [
		Vector3(-10.0, 0.2, 10.0),
		Vector3(10.0, 0.2, 10.0),
		Vector3(-10.0, 0.2, -10.0),
		Vector3(10.0, 0.2, -10.0),
	]
	for index: int in range(benches.size()):
		_add_block(furniture, "Bench%d" % index, benches[index], Vector3(2.0, 0.4, 0.6), stone, true)
	_add_model_prop(furniture, "PlazaJarWest", MODEL_PROP_JAR, Vector3(-11.5, 0.0, 9.0), 0.3, 1.0)
	_add_model_prop(furniture, "PlazaJarEast", MODEL_PROP_JAR, Vector3(11.5, 0.0, 9.0), -0.4, 1.0)
	_add_model_prop(furniture, "PlazaFirewood", MODEL_PROP_FIREWOOD, Vector3(-11.0, 0.0, -9.5), 0.6, 1.0)


## Altar y cántaros del santuario: el recinto se lee como lugar de ofrenda y no
## como un pedestal vacío.
func _build_sanctuary_props() -> void:
	var props: Node3D = Node3D.new()
	props.name = "SanctuaryProps"
	add_child(props)
	var stone: ShaderMaterial = SurfaceMaterials.layer_material(SurfaceMaterials.Layer.STONE, STONE_TINT)
	_add_block(props, "Altar", Vector3(0.0, 1.95, -15.8), Vector3(1.6, 0.3, 0.8), stone, true)
	_add_model_prop(props, "SanctuaryJarWest", MODEL_PROP_JAR, Vector3(-5.2, 0.0, -18.0), 0.2, 1.1)
	_add_model_prop(props, "SanctuaryJarEast", MODEL_PROP_JAR, Vector3(5.2, 0.0, -18.0), -0.2, 1.1)


## Matas de ichu junto a los muros: rompen la tierra desnuda sin invadir la
## plaza, los caminos ni las casas.
func _build_vegetation() -> void:
	var vegetation: Node3D = Node3D.new()
	vegetation.name = "Vegetation"
	add_child(vegetation)
	var clumps: Array[Array] = [
		["pch_ichu_a.glb", Vector3(-27.0, 0.0, -26.0), 0.9],
		["pch_ichu_b.glb", Vector3(27.0, 0.0, -26.0), 0.8],
		["pch_ichu_a.glb", Vector3(-27.0, 0.0, 26.0), 1.0],
		["pch_ichu_b.glb", Vector3(27.0, 0.0, 26.0), 0.9],
		["pch_ichu_a.glb", Vector3(-28.0, 0.0, 0.0), 0.8],
		["pch_ichu_b.glb", Vector3(28.0, 0.0, 0.0), 1.0],
		["pch_ichu_a.glb", Vector3(-5.0, 0.0, 27.5), 0.8],
		["pch_ichu_b.glb", Vector3(5.0, 0.0, 27.5), 0.9],
	]
	for index: int in range(clumps.size()):
		var entry: Array = clumps[index]
		var file: String = entry[0]
		var at: Vector3 = entry[1]
		var model_scale: float = entry[2]
		_add_model_prop(vegetation, "Ichu%d" % index, file, at, 0.7 * float(index), model_scale)


## Modelo suelto con material del proyecto, para props y vegetación.
func _add_model_prop(
	parent: Node3D,
	node_name: String,
	file: String,
	at: Vector3,
	yaw: float,
	model_scale: float = 1.0
) -> ModelSlot:
	var slot: ModelSlot = ModelSlot.new()
	slot.name = node_name
	slot.position = at
	slot.rotation.y = yaw
	slot.scale = Vector3.ONE * model_scale
	var paths: Array[String] = [MODEL_DIR + file]
	slot.model_paths = paths
	parent.add_child(slot)
	SurfaceMaterials.apply_to_model(slot.model)
	return slot


## Terrazas de cultivo al este del muro: tres fajas de tierra sostenidas por
## pirca, visibles por encima de la muralla.
func _build_terraces() -> void:
	var terraces: Node3D = Node3D.new()
	terraces.name = "Terraces"
	add_child(terraces)
	var stone: ShaderMaterial = SurfaceMaterials.layer_material(SurfaceMaterials.Layer.STONE, STONE_TINT, true)
	var soil: ShaderMaterial = SurfaceMaterials.layer_material(SurfaceMaterials.Layer.SOIL, SOIL_TINT)
	for index: int in range(3):
		var x: float = 36.0 + 8.0 * float(index)
		var top: float = 0.8 * float(index + 1)
		_add_block(terraces, "Field%d" % index, Vector3(x, top * 0.5, 0.0), Vector3(8.0, top, 30.0), soil, true)
		_add_block(terraces, "FieldTop%d" % index, Vector3(x, top + 0.01, 0.0), Vector3(8.0, 0.02, 30.0), soil, false)
		var faces: Array[StoneWall.Face] = [
			StoneWall.Face.new(Vector3(x - 4.0, 0.0, -15.0), Vector3(0.0, 0.0, 1.0), Vector3(-1.0, 0.0, 0.0), 30.0, top),
		]
		var wall: MeshInstance3D = MeshInstance3D.new()
		wall.name = "Wall%d" % index
		wall.mesh = StoneWall.build(faces, 700 + index)
		wall.material_override = stone
		terraces.add_child(wall)


## Multitud de refugiados y vecinos: figuras vestidas que no interactúan. Se
## colocan en el borde de la plaza y miran al centro; dan escala y vida.
func _build_crowd() -> void:
	var crowd: Node3D = Node3D.new()
	crowd.name = "Crowd"
	add_child(crowd)
	for index: int in range(CROWD_POSITIONS.size()):
		_add_crowd_figure(crowd, index, CROWD_POSITIONS[index], CROWD_ROLES[index], CROWD_VARIANTS[index])


func _add_crowd_figure(parent: Node3D, index: int, at: Vector3, role: StringName, variant: int) -> void:
	var visual: MannequinVisual = MannequinVisual.new()
	visual.name = "Crowd%02d" % index
	visual.skin = true
	visual.tint = DressedMannequin.SKIN_COLOR
	visual.position = at
	parent.add_child(visual)
	var outfit: DressedMannequin = DressedMannequin.new()
	outfit.name = "Outfit"
	outfit.role = role
	outfit.variant = variant
	visual.add_child(outfit)
	var body: StaticBody3D = StaticBody3D.new()
	body.name = "CrowdBody"
	body.collision_layer = CROWD_COLLISION_LAYER
	body.collision_mask = 0
	var shape: CollisionShape3D = CollisionShape3D.new()
	var capsule: CapsuleShape3D = CapsuleShape3D.new()
	capsule.radius = 0.28
	capsule.height = 1.7
	shape.shape = capsule
	shape.position = Vector3(0.0, 0.85, 0.0)
	body.add_child(shape)
	visual.add_child(body)
	var target: Vector3 = Vector3(0.0, at.y, 0.0)
	if at.distance_to(target) > 0.1:
		visual.look_at(target, Vector3.UP)
	visual.play(&"Idle", 0.85 + 0.1 * float(index % 3))
	_crowd.append(CrowdMember.new(visual, CROWD_SAFE_POSITIONS[index]))


## Bloque con material del proyecto; si [param collision] es verdadero, el
## bloque es un cuerpo estático con su malla y su caja de colisión.
func _add_block(
	parent: Node3D,
	node_name: String,
	at: Vector3,
	size: Vector3,
	material: Material,
	collision: bool
) -> Node3D:
	var root: Node3D = null
	if collision:
		root = _add_collision_box(parent, node_name, at, size)
	else:
		root = Node3D.new()
		root.name = node_name
		root.position = at
		parent.add_child(root)
	var mesh_instance: MeshInstance3D = MeshInstance3D.new()
	var box: BoxMesh = BoxMesh.new()
	box.size = size
	mesh_instance.mesh = box
	mesh_instance.material_override = material
	root.add_child(mesh_instance)
	return root


func _add_collision_box(parent: Node3D, node_name: String, at: Vector3, size: Vector3) -> StaticBody3D:
	var body: StaticBody3D = StaticBody3D.new()
	body.name = node_name
	body.position = at
	body.collision_layer = 1
	body.collision_mask = 0
	var shape: CollisionShape3D = CollisionShape3D.new()
	var box_shape: BoxShape3D = BoxShape3D.new()
	box_shape.size = size
	shape.shape = box_shape
	body.add_child(shape)
	parent.add_child(body)
	return body


static func _ally_key(index: int) -> StringName:
	return StringName("aliado_%d" % index)
