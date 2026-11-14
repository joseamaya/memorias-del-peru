extends Node3D
## Acto II en gris: el paso de montaña y la emboscada chanca.
##
## Prueba el arco del acto II con geometría de bloqueo, sin arte final: sendero,
## roquedales, refugio y arroyo; cuatro exploradores con moral y huida; honda
## del jugador y escudo. No es la versión definitiva: es el arnés para probar
## distancia, cobertura y decisiones antes de invertir en arte.

const PASS_SIZE: float = 80.0
const GROUND_COLOR: Color = Color(0.36, 0.38, 0.30, 1.0)
const PATH_COLOR: Color = Color(0.46, 0.36, 0.23, 1.0)
const STONE_COLOR: Color = Color(0.48, 0.46, 0.42, 1.0)
const WATER_COLOR: Color = Color(0.25, 0.44, 0.58, 1.0)
const ENEMY_POSITIONS: Array[Vector3] = [
	Vector3(5.0, 0.0, -2.0),
	Vector3(-5.0, 0.0, -4.0),
	Vector3(8.0, 0.0, -10.0),
	Vector3(-8.0, 0.0, -12.0),
]
const PLAYER_DAMAGE_BLOCKED: float = 0.3
const CAMP_SCENE: String = "res://campaigns/01_pachacutec/scenes/objects/camp_point.tscn"
const CAMP_POSITION: Vector3 = Vector3(-4.0, 0.9, 18.0)

@onready var player: PlayerFPS = $PlayerFPS
@onready var hud: PlayerHud = $UILayer/HUD
@onready var status_label: Label = $UILayer/StatusLabel
@onready var hint_label: Label = $UILayer/HintLabel
@onready var spawn: Marker3D = $PlayerSpawn

var character: CharacterState = null
var player_combatant: Combatant = null
var inventory: Inventory = null
var dialogue: DialogueRunner = null

var _camp_graph: DialogueGraph = null
var _aftermath_graph: DialogueGraph = null
var _aftermath_pending: bool = false
var _dialogue_speaker: StringName = &""
var _dialogue_text: StringName = &""

var _enemies: Array[AmbushEnemy] = []
var _attack_ray: RayCast3D = null
var _sling: CombatWeapon = null
var _ambush_started: bool = false
var _completed: bool = false
var _dead: bool = false
var _blocking: bool = false


func _ready() -> void:
	player.global_position = spawn.global_position
	hud.bind(player, player.stamina)
	_build_greybox()
	_setup_player_combat()
	_setup_inventory_and_dialogue()
	_setup_camp()
	_setup_enemies()
	_setup_trigger()
	hint_label.text = ""
	_update_status()


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
	if not character.is_alive():
		_dead = true
		hint_label.text = tr("PCH_PASO_DEAD")
	_update_status()


## Un enemigo se resolvió; actualiza la cuenta.
func on_enemy_resolved() -> void:
	_update_status()


func _physics_process(_delta: float) -> void:
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
	if event is InputEventKey:
		var key: InputEventKey = event as InputEventKey
		if key.pressed and not key.echo and key.keycode == KEY_R and (_dead or _completed):
			get_tree().reload_current_scene()


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


func _start_ambush() -> void:
	if _ambush_started or _completed or _dead:
		return
	_ambush_started = true
	hud.show_subtitle(tr("PCH_PASO_AMBUSH"), 0.0)
	_update_status()


func _finish_ambush() -> void:
	if _completed or _aftermath_pending:
		return
	_aftermath_pending = true
	hud.show_subtitle(tr("PCH_PASO_CLEAR"), 0.0)
	if dialogue != null and _aftermath_graph != null and dialogue.start(_aftermath_graph):
		player.process_mode = Node.PROCESS_MODE_DISABLED
	else:
		_aftermath_pending = false
		_completed = true
		hint_label.text = tr("PCH_PASO_END")


func _update_status() -> void:
	if status_label == null or character == null:
		return
	status_label.text = tr("PCH_PASO_STATUS") % [int(character.get_health()), alive_enemies()]


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
	var fire: MeshInstance3D = MeshInstance3D.new()
	var cylinder: CylinderMesh = CylinderMesh.new()
	cylinder.top_radius = 0.25
	cylinder.bottom_radius = 0.5
	cylinder.height = 0.4
	fire.mesh = cylinder
	fire.position = Vector3(CAMP_POSITION.x, 0.2, CAMP_POSITION.z)
	var fire_material: StandardMaterial3D = StandardMaterial3D.new()
	fire_material.albedo_color = Color(0.95, 0.45, 0.15, 1.0)
	fire_material.emission_enabled = true
	fire_material.emission = Color(1.0, 0.4, 0.1, 1.0)
	fire_material.emission_energy_multiplier = 2.0
	fire.material_override = fire_material
	add_child(fire)
	var light: OmniLight3D = OmniLight3D.new()
	light.position = Vector3(CAMP_POSITION.x, 1.4, CAMP_POSITION.z)
	light.light_color = Color(1.0, 0.62, 0.32, 1.0)
	light.light_energy = 1.4
	light.omni_range = 7.0
	add_child(light)
	_add_camp_npc(Vector3(-5.4, 0.0, 17.2), Color(0.7, 0.55, 0.42, 1.0))
	_add_camp_npc(Vector3(-2.6, 0.0, 17.4), Color(0.48, 0.36, 0.28, 1.0))
	_add_camp_npc(Vector3(-4.2, 0.0, 19.4), Color(0.55, 0.42, 0.32, 1.0))
	var instance: Node = (load(CAMP_SCENE) as PackedScene).instantiate()
	var camp: CampPoint = instance as CampPoint
	var body: Node3D = instance as Node3D
	if camp == null or body == null:
		instance.free()
		return
	body.position = CAMP_POSITION
	add_child(camp)
	camp.requested.connect(_on_camp_requested)


func _add_camp_npc(at: Vector3, color: Color) -> void:
	var mesh_instance: MeshInstance3D = MeshInstance3D.new()
	var capsule: CapsuleMesh = CapsuleMesh.new()
	capsule.radius = 0.35
	capsule.height = 1.75
	mesh_instance.mesh = capsule
	mesh_instance.position = at + Vector3(0.0, 0.875, 0.0)
	var material: StandardMaterial3D = StandardMaterial3D.new()
	material.albedo_color = color
	material.roughness = 1.0
	mesh_instance.material_override = material
	add_child(mesh_instance)


func _on_camp_requested() -> void:
	if dialogue == null or _camp_graph == null or _completed or _dead:
		return
	if dialogue.is_active():
		return
	if dialogue.start(_camp_graph):
		player.process_mode = Node.PROCESS_MODE_DISABLED


func _build_camp_dialogue() -> DialogueGraph:
	var graph: DialogueGraph = DialogueGraph.new()
	graph.entry_id = &"start"
	var start: DialogueNode = DialogueNode.new()
	start.id = &"start"
	start.speaker_key = &"PCH_NPC_CURACA"
	start.text_key = &"PCH_CAMP_INTRO"
	start.next_id = &"end"
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
	var choices: Array[DialogueChoice] = [rest, push, share, leave]
	start.choices = choices
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
	var nodes: Array[DialogueNode] = [start, rest_node, push_node, coca_node]
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
	var abandon_node: DialogueNode = _dialogue_answer(&"maize_abandon", &"PCH_AFTER_MAIZE_ABANDON", &"maiz_abandonado")
	var nodes: Array[DialogueNode] = [start, carry_node, leave_node, maize, keep_node, abandon_node]
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
	player.process_mode = Node.PROCESS_MODE_INHERIT
	if _aftermath_pending:
		_aftermath_pending = false
		_completed = true
		hint_label.text = tr("PCH_PASO_END")


func _on_dialogue_flag(key: StringName, value: int) -> void:
	CampaignState.set_flag(key, value)
	if key == &"descanso" and value != 0 and character != null:
		character.heal(25.0)


func _setup_enemies() -> void:
	for index: int in range(ENEMY_POSITIONS.size()):
		var enemy: AmbushEnemy = AmbushEnemy.new()
		enemy.name = "Ambusher%d" % (index + 1)
		enemy.position = ENEMY_POSITIONS[index]
		add_child(enemy)
		enemy.setup(player, self)
		_enemies.append(enemy)


func _setup_trigger() -> void:
	var trigger: Area3D = Area3D.new()
	trigger.name = "AmbushTrigger"
	trigger.collision_layer = 0
	trigger.collision_mask = 2
	trigger.position = Vector3(0.0, 2.0, 8.0)
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


func _build_greybox() -> void:
	_add_box("Ground", Vector3(0.0, -0.5, 0.0), Vector3(PASS_SIZE, 1.0, PASS_SIZE), GROUND_COLOR, true)
	_add_box("Path", Vector3(0.0, 0.02, 0.0), Vector3(4.0, 0.04, 70.0), PATH_COLOR, false)
	_add_box("Stream", Vector3(-12.0, 0.03, 0.0), Vector3(6.0, 0.02, 70.0), WATER_COLOR, false)
	var rocks: Array[Vector3] = [
		Vector3(7.0, 0.6, 6.0), Vector3(-7.0, 0.5, 4.0),
		Vector3(10.0, 0.8, -2.0), Vector3(-10.0, 0.7, -6.0),
		Vector3(6.0, 0.5, -14.0), Vector3(-6.0, 0.6, -16.0),
	]
	for index: int in range(rocks.size()):
		var size: Vector3 = Vector3(2.4, 1.2 + 0.2 * float(index % 2), 2.0)
		_add_box("Rock%d" % (index + 1), rocks[index], size, STONE_COLOR, true)
	_add_box("ShelterBack", Vector3(14.0, 1.0, 0.0), Vector3(0.4, 2.0, 5.0), STONE_COLOR, true)
	_add_box("ShelterSide", Vector3(12.0, 1.0, -2.3), Vector3(4.0, 2.0, 0.4), STONE_COLOR, true)
	_add_box("ShelterRoof", Vector3(14.0, 2.1, 0.0), Vector3(4.4, 0.2, 5.0), STONE_COLOR, true)


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
