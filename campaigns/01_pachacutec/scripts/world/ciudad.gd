extends Node3D
## Acto III en gris: el Cusco de 1438, el reclutamiento y la defensa.
##
## La ciudad es un bloqueo: plaza, santuario, casas y muro. El jugador recluta a
## tres grupos según lo que hizo en el acto II (banderas de `CampaignState`),
## habla con Cusi Yupanqui y sostiene la defensa. La victoria es fija; el
## epílogo cambia con las decisiones anteriores.

const CIUDAD_SIZE: float = 120.0
const GROUND_COLOR: Color = Color(0.36, 0.38, 0.30, 1.0)
const PLAZA_COLOR: Color = Color(0.46, 0.36, 0.23, 1.0)
const STONE_COLOR: Color = Color(0.48, 0.46, 0.42, 1.0)
const HOUSE_COLOR: Color = Color(0.55, 0.47, 0.36, 1.0)
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
const RECRUIT_COLORS: Array[Color] = [
	Color(0.52, 0.4, 0.3, 1.0),
	Color(0.68, 0.53, 0.4, 1.0),
	Color(0.46, 0.35, 0.27, 1.0),
]
const ALLY_POSITIONS: Array[Vector3] = [
	Vector3(-4.0, 0.0, 2.0),
	Vector3(4.0, 0.0, 2.0),
	Vector3(0.0, 0.0, 5.0),
]

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
var _dialogue_speaker: StringName = &""
var _dialogue_text: StringName = &""
var _ally_visuals: Dictionary[int, bool] = {}


func _ready() -> void:
	player.global_position = spawn.global_position
	hud.bind(player, player.stamina)
	_build_greybox()
	_setup_player_combat()
	_setup_inventory_and_dialogue()
	_setup_journal()
	_setup_recruitment()
	_setup_cusi()
	_setup_vespera()
	_restore_allies()
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
	_attack_ray.force_raycast_update()
	if not _attack_ray.is_colliding():
		return
	var enemy: AmbushEnemy = _attack_ray.get_collider() as AmbushEnemy
	if enemy != null:
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
		_add_visual_npc(Vector3(RECRUIT_POSITIONS[index].x, 0.0, RECRUIT_POSITIONS[index].z), RECRUIT_COLORS[index])


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
	_add_visual_npc(Vector3(CUSI_POSITION.x, 0.0, CUSI_POSITION.z), Color(0.72, 0.55, 0.42, 1.0))


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
	_add_visual_npc(Vector3(VESPERA_POSITION.x, 0.0, VESPERA_POSITION.z), Color(0.58, 0.55, 0.48, 1.0))


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


func _finish_defense() -> void:
	if _completed:
		return
	_completed = true
	_defense_active = false
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


func _update_status() -> void:
	if status_label == null or character == null:
		return
	status_label.text = tr("PCH_CIUDAD_STATUS") % [int(character.get_health()), ally_count(), alive_enemies()]


func _restore_allies() -> void:
	for index: int in range(3):
		if CampaignState.has_flag(_ally_key(index)):
			_add_ally_visual(index)


func _add_visual_npc(at: Vector3, color: Color) -> void:
	var visual: MannequinVisual = MannequinVisual.new()
	visual.name = "Visual"
	visual.tint = color
	visual.position = at
	add_child(visual)


func _add_ally_visual(index: int) -> void:
	if _ally_visuals.has(index):
		return
	_ally_visuals[index] = true
	var visual: MannequinVisual = MannequinVisual.new()
	visual.name = "Ally%d" % index
	visual.tint = Color(0.35, 0.45, 0.55, 1.0)
	visual.position = ALLY_POSITIONS[index]
	add_child(visual)


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


func _build_greybox() -> void:
	_add_box("Ground", Vector3(0.0, -0.5, 0.0), Vector3(CIUDAD_SIZE, 1.0, CIUDAD_SIZE), GROUND_COLOR, true)
	_add_box("Plaza", Vector3(0.0, 0.02, 0.0), Vector3(40.0, 0.04, 40.0), PLAZA_COLOR, false)
	_add_box("Shrine", Vector3(0.0, 1.5, -18.0), Vector3(6.0, 3.0, 6.0), STONE_COLOR, true)
	_add_box("ShrineStep", Vector3(0.0, 0.2, -14.5), Vector3(8.0, 0.4, 2.0), STONE_COLOR, true)
	var houses: Array[Vector3] = [
		Vector3(-20.0, 1.5, -5.0), Vector3(-22.0, 1.5, 10.0),
		Vector3(20.0, 1.5, -5.0), Vector3(22.0, 1.5, 10.0),
		Vector3(-15.0, 1.5, 22.0), Vector3(15.0, 1.5, 22.0),
	]
	for index: int in range(houses.size()):
		_add_box("House%d" % (index + 1), houses[index], Vector3(6.0, 3.0, 5.0), HOUSE_COLOR, true)
	_add_box("WallNorth", Vector3(0.0, 1.0, -28.0), Vector3(50.0, 2.0, 1.0), STONE_COLOR, true)
	_add_box("WallWest", Vector3(-28.0, 1.0, 0.0), Vector3(1.0, 2.0, 56.0), STONE_COLOR, true)
	_add_box("WallEast", Vector3(28.0, 1.0, 0.0), Vector3(1.0, 2.0, 56.0), STONE_COLOR, true)


func _add_box(
	box_name: String,
	box_position: Vector3,
	box_size: Vector3,
	color: Color,
	collision: bool
) -> Node3D:
	var root: Node3D = null
	if collision:
		var body: StaticBody3D = StaticBody3D.new()
		body.collision_layer = 1
		body.collision_mask = 0
		var shape: CollisionShape3D = CollisionShape3D.new()
		var box_shape: BoxShape3D = BoxShape3D.new()
		box_shape.size = box_size
		shape.shape = box_shape
		body.add_child(shape)
		root = body
	else:
		root = Node3D.new()
	root.name = box_name
	root.position = box_position
	var mesh_instance: MeshInstance3D = MeshInstance3D.new()
	var mesh: BoxMesh = BoxMesh.new()
	mesh.size = box_size
	mesh_instance.mesh = mesh
	var material: StandardMaterial3D = StandardMaterial3D.new()
	material.albedo_color = color
	material.roughness = 1.0
	mesh_instance.material_override = material
	root.add_child(mesh_instance)
	add_child(root)
	return root


static func _ally_key(index: int) -> StringName:
	return StringName("aliado_%d" % index)
