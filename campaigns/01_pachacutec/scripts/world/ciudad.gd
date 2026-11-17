extends Node3D
## Acto III en gris: el Cusco de 1438, el reclutamiento y la defensa.
##
## La ciudad es un bloqueo: plaza, santuario, casas y muro. El jugador recluta a
## tres grupos según lo que hizo en el acto II (banderas de `CampaignState`),
## habla con Cusi Yupanqui y sostiene la defensa. La victoria es fija; el
## epílogo cambia con las decisiones anteriores.

const CITY_SIZE: float = 150.0
## Lado del terreno visible. La colisión sigue en [constant CITY_SIZE].
const CITY_TERRAIN_SIZE: float = 520.0
## Resolución de la malla de terreno visible y radio plano de la ciudad.
const TERRAIN_RESOLUTION: int = 128
const TERRAIN_FLAT_RADIUS: float = 31.0
const WALL_RADIUS: float = 30.0
const BOUNDARY_RADIUS: float = 70.0
const GRASS_COLOR: Color = Color(0.33, 0.36, 0.24, 1.0)
const ROCK_COLOR: Color = Color(0.46, 0.44, 0.40, 1.0)
const DIRT_COLOR: Color = Color(0.47, 0.38, 0.26, 1.0)
const STONE_TINT: Color = Color(0.52, 0.50, 0.46, 1.0)
const THATCH_TINT: Color = Color(0.50, 0.40, 0.22, 1.0)
const SOIL_TINT: Color = Color(0.34, 0.27, 0.19, 1.0)
const MODEL_DIR: String = "res://campaigns/01_pachacutec/assets/models/"
## Cúpula de nubes procedurales, la misma que usan la llacta y el paso.
const CLOUD_SHADER_PATH: String = "res://shared_assets/materials/nubes.gdshader"
const CLOUD_DOME_RADIUS: float = 420.0
const CLOUD_DOME_SEGMENTS: int = 48
const CLOUD_DOME_RINGS: int = 24
const MODEL_HOUSES: Array[String] = ["pch_house_a.glb", "pch_house_b.glb", "pch_house_c.glb", "pch_house_d.glb", "pch_house_e.glb"]
const MODEL_PROP_JAR: String = "pch_prop_jar.glb"
const MODEL_PROP_FIREWOOD: String = "pch_prop_firewood.glb"
const HOUSE_DEPTHS: Array[float] = [5.0, 4.6, 4.0, 5.4, 3.8]
const HOUSE_LEFT_PROP_X: Array[float] = [-2.1, -2.4, -1.7, -2.5, -1.5]
const HOUSE_YAW_JITTER: Array[float] = [7.0, -11.0, 4.0, -6.0, 10.0, -8.0, 5.0, -4.0]
## Catorce casas con tres modelos: la escala y el tinte rompen la repetición sin
## generar geometría nueva.
const HOUSE_SCALES: Array[float] = [1.0, 0.94, 1.06, 0.97, 1.03]
const HOUSE_TINTS: Array[Color] = [
	Color(1.0, 1.0, 1.0),
	Color(0.96, 0.94, 0.90),
	Color(1.0, 0.98, 0.93),
	Color(0.94, 0.95, 0.98),
	Color(1.0, 0.97, 0.91),
	Color(0.98, 0.99, 0.97),
]
## Catorce viviendas alrededor de la plaza, fuera de los caminos y del santuario.
const HOUSE_POSITIONS: Array[Vector3] = [
	Vector3(-22.0, 0.0, -19.0),
	Vector3(-27.0, 0.0, -6.0),
	Vector3(-22.0, 0.0, 5.0),
	Vector3(-25.0, 0.0, 15.0),
	Vector3(-16.0, 0.0, 23.0),
	Vector3(23.0, 0.0, -17.0),
	Vector3(27.0, 0.0, -8.0),
	Vector3(21.0, 0.0, 3.0),
	Vector3(25.0, 0.0, 11.0),
	Vector3(18.0, 0.0, 24.0),
	Vector3(-10.0, 0.0, -26.0),
	Vector3(13.0, 0.0, -23.0),
	Vector3(-7.0, 0.0, 27.0),
	Vector3(10.0, 0.0, 27.0),
]
## Refugiados y vecinos que llenan la plaza; no interactúan, solo dan escala.
const CROWD_POSITIONS: Array[Vector3] = [
	Vector3(-18.0, 0.0, 10.0),
	Vector3(-11.0, 0.0, 3.4),
	Vector3(-18.0, 0.0, -4.0),
	Vector3(18.0, 0.0, 10.0),
	Vector3(11.0, 0.0, 3.4),
	Vector3(18.0, 0.0, -4.0),
	Vector3(-9.0, 0.0, 16.0),
	Vector3(3.6, 0.0, 7.4),
	Vector3(-3.6, 0.0, 7.4),
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
## Distancia a la que un vecino quieto gira la cara hacia el jugador.
const CROWD_LOOK_DISTANCE: float = 5.0
## Velocidad del giro de la cara, en radianes por segundo (suavizada).
const CROWD_LOOK_SPEED: float = 5.0
## Paseo cotidiano de la multitud: velocidad, pausas y radio de reacción.
const CROWD_WALK_SPEED: float = 1.15
const CROWD_PAUSE_MIN: float = 3.0
const CROWD_PAUSE_MAX: float = 7.0
const CROWD_REACT_DISTANCE: float = 4.0
const CROWD_REACT_SECONDS: float = 2.4
const CROWD_ACTIVITY_MIN: float = 5.0
const CROWD_ACTIVITY_MAX: float = 9.0
## Actividad de reposo de cada figura: paseo, conversación de pareja, puesto o
## descanso. Los índices se corresponden con [constant CROWD_POSITIONS].
const CROWD_ACTIVITIES: Array[StringName] = [
	&"idle_b", &"talk", &"talk", &"idle_b", &"talk",
	&"talk", &"idle_b", &"talk", &"talk", &"tired",
]
## Parejas que conversan de frente: índices en [constant CROWD_POSITIONS].
const CROWD_PAIRS: Array[Vector2i] = [Vector2i(7, 8)]
## Puestos atendidos: índice de la figura y posición detrás del mostrador.
const CROWD_VENDORS: Dictionary[int, Vector3] = {
	2: Vector3(-8.5, 0.0, -6.2),
	5: Vector3(8.5, 0.0, -6.2),
}
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
const ARRIVAL_POSITION: Vector3 = Vector3(0.0, 0.9, 24.0)
const CUSI_POSITION: Vector3 = Vector3(0.0, 0.9, -12.0)
const PREP_POSITIONS: Array[Vector3] = [
	Vector3(-10.0, 0.9, -5.0),
	Vector3(10.0, 0.9, -5.0),
	Vector3(10.0, 0.9, 6.0),
	Vector3(-10.0, 0.9, 6.0),
]
const PREP_PROMPTS: Array[StringName] = [
	&"PCH_PREP_MURO", &"PCH_PREP_MAIZ", &"PCH_PREP_AGUA", &"PCH_PREP_HONDAS",
]
const PREP_OFICIOS: Array[StringName] = [&"pirca", &"maiz", &"agua", &"telar"]
const TRAP_POSITION: Vector3 = Vector3(5.0, 0.9, -10.0)
const DEFENSE_WAVES: int = 3
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

## Figura de multitud con su rutina, su pareja y su destino de retirada.
class CrowdMember:
	var visual: CharacterModelVisual
	var safe_position: Vector3
	## Orientación de reposo: mirando al centro de la plaza.
	var home_yaw: float = 0.0
	var retreating: bool = false
	var home: Vector3 = Vector3.ZERO
	var route: PackedVector3Array = PackedVector3Array()
	var route_index: int = 0
	var pause_left: float = 0.0
	var activity: StringName = &"idle_b"
	var activity_left: float = 0.0
	var pair: int = -1
	var reacting_left: float = 0.0
	var react_cooldown: float = 0.0
	var speed: float = 0.0
	var rng: RandomNumberGenerator = RandomNumberGenerator.new()

	func _init(figure: CharacterModelVisual, safe: Vector3, yaw: float) -> void:
		visual = figure
		safe_position = safe
		home_yaw = yaw


@onready var player: PlayerFPS = $PlayerFPS
@onready var hud: PlayerHud = $UILayer/HUD
@onready var hint_label: Label = $UILayer/HintLabel
@onready var spawn: Marker3D = $PlayerSpawn

var character: CharacterState = null
var player_combatant: Combatant = null
var inventory: Inventory = null
var dialogue: DialogueRunner = null
var journal: Journal = null

var _enemies: Array[AmbushEnemy] = []
var _attack_ray: RayCast3D = null
var loadout: CombatLoadout = null
var _director: EncounterDirector = null
var _hit_stop: HitStop = null
var _camera_kick: CameraKick = null
var _pending_damage: float = 0.0
var _defense_active: bool = false
var _defense_requested: bool = false
var _wave: int = 0
var _trap_resolved: bool = false
var _cost_applied: bool = false
var _completed: bool = false
var _dead: bool = false
var _blocking: bool = false
var _battle_drum: AudioStreamPlayer = null
var _dialogue_speaker: StringName = &""
var _dialogue_text: StringName = &""
var _ally_visuals: Dictionary[int, bool] = {}
var _recruit_visuals: Array[CharacterModelVisual] = []
var _arrival_point: CampPoint = null
var _cusi_point: CampPoint = null
var _trap_point: CampPoint = null
var _vespera_point: CampPoint = null
var _prep_points: Array[CampPoint] = []
var _recruit_points: Array[CampPoint] = []
var _cusi_visual: CharacterModelVisual = null
var _trap_visual: CharacterModelVisual = null
var _vespera_visual: CharacterModelVisual = null
var _anca_visual: CharacterModelVisual = null
var _young_visual: CharacterModelVisual = null
var _cusi_move_pending: bool = false
## Orientación de reposo de cada figura que no es multitud (Cusi, reclutas,
## aliados): al acercarse el jugador, giran la cabeza/cuerpo y luego vuelven.
var _idle_visual_home: Dictionary[CharacterModelVisual, float] = {}
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
	CampaignProgress.apply(self)
	if CampaignProgress.is_respawn_pending():
		CampaignProgress.restore_checkpoint(self)
	_sync_loadout_ammo()
	_setup_arrival()
	_setup_preparation()
	_setup_trap()
	_setup_recruitment()
	_setup_cusi()
	_setup_vespera()
	_restore_allies()
	_setup_audio()
	_bind_environment()
	hint_label.text = ""
	hud.show_subtitle(tr("PCH_CIUDAD_ARRIVAL"), 0.0)
	if CampaignState.has_flag(&"mensaje_entregado"):
		hud.show_objective(tr("PCH_OBJ_RECRUIT"))
	else:
		hud.show_objective(tr("PCH_CIUDAD_TALK_MESSAGE"))
	_update_status()
	CampaignProgress.save_checkpoint(self, player.global_position)
	SessionLog.mark(&"act", "cusco")


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
func apply_player_damage(amount: float, source: Node = null) -> void:
	if _dead or _completed or character == null:
		return
	var parried: bool = loadout != null and loadout.is_parry_window()
	var applied: float = amount
	if loadout != null:
		applied = loadout.resolve_incoming_damage(amount)
	if parried and source is AmbushEnemy:
		(source as AmbushEnemy).stagger()
	character.damage(applied)
	if hud != null:
		hud.flash_damage()
	if _camera_kick != null and applied > 0.0:
		_camera_kick.kick(-1.4, 0.9)
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
		if _wave < DEFENSE_WAVES:
			_wave += 1
			_spawn_wave()
			hud.show_subtitle(tr("PCH_CIUDAD_WAVE") % _wave, 0.0)
			if _wave == DEFENSE_WAVES:
				# El coste cae al empezar la última oleada, no después de la batalla.
				_apply_defense_cost()
		else:
			_finish_defense()
	_update_status()


func _process(delta: float) -> void:
	_update_crowd(delta)
	_update_idle_visuals(delta)


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("journal"):
		if hud == null or journal == null or _completed or _dead or _defense_active:
			return
		if hud.is_dialogue_open():
			return
		if hud.is_journal_open():
			hud.hide_journal()
			player.set_controls_locked(false)
		else:
			hud.show_journal(journal)
			player.set_controls_locked(true)
		get_viewport().set_input_as_handled()
		return
	if event.is_action_pressed("attack"):
		_attack()
		get_viewport().set_input_as_handled()
		return
	if event.is_action_pressed("block"):
		_blocking = true
		if loadout != null:
			loadout.set_blocking(true)
		get_viewport().set_input_as_handled()
		return
	if event.is_action_released("block"):
		_blocking = false
		if loadout != null:
			loadout.set_blocking(false)
		get_viewport().set_input_as_handled()
		return
	if event.is_action_pressed("weapon_1"):
		_switch_weapon(CombatLoadout.Slot.SLING)
		get_viewport().set_input_as_handled()
		return
	if event.is_action_pressed("weapon_2"):
		_switch_weapon(CombatLoadout.Slot.CLUB)
		get_viewport().set_input_as_handled()
		return
	if event.is_action_pressed("weapon_3"):
		_switch_weapon(CombatLoadout.Slot.SHIELD)
		get_viewport().set_input_as_handled()
		return
	if _completed and _advance_requested(event):
		get_viewport().set_input_as_handled()
		CampaignProgress.save(self)
		get_tree().change_scene_to_file("res://campaigns/01_pachacutec/scenes/world/llacta_act4.tscn")
		return
	if _dead and _retry_requested(event):
		get_viewport().set_input_as_handled()
		CampaignProgress.request_respawn()
		get_tree().reload_current_scene()


func _attack() -> void:
	if not is_ambush_active() or loadout == null or _attack_ray == null:
		return
	var damage: float = loadout.attack(1.0)
	if damage <= 0.0:
		return
	_pending_damage = damage
	CampaignAudio.play_sfx(CampaignAudio.WHOOSH_PATH if loadout.is_ranged()
		else CampaignAudio.PORRA_PATH, -12.0)


func _on_attack_started(weapon: CombatWeapon) -> void:
	var weapon_visual: FirstPersonWeapon = player.get_node_or_null("Head/Camera3D/FirstPersonWeapon") as FirstPersonWeapon
	if weapon_visual != null and weapon != null:
		weapon_visual.play_attack(
			weapon.windup_seconds + weapon.active_seconds, weapon.recovery_seconds)


func _on_attack_active(weapon: CombatWeapon) -> void:
	if weapon == null or _attack_ray == null or _pending_damage <= 0.0:
		return
	_attack_ray.target_position = Vector3(0.0, 0.0, -maxf(weapon.range_max, 0.5))
	_attack_ray.force_raycast_update()
	if not _attack_ray.is_colliding():
		return
	var enemy: AmbushEnemy = _attack_ray.get_collider() as AmbushEnemy
	if enemy == null:
		return
	loadout.register_hit()
	CampaignAudio.play_sfx(CampaignAudio.IMPACT_PATH, -6.0)
	enemy.take_hit(_pending_damage)
	if _hit_stop != null:
		_hit_stop.trigger(0.055)
	if _camera_kick != null:
		_camera_kick.kick(-1.8, 0.8)
	_update_status()


func _on_parried() -> void:
	CampaignAudio.play_sfx(CampaignAudio.PORRA_PATH, -13.0)
	if _camera_kick != null:
		_camera_kick.kick(-1.2, -0.6)


func _on_blocked() -> void:
	CampaignAudio.play_sfx(CampaignAudio.IMPACT_PATH, -9.0)
	if _camera_kick != null:
		_camera_kick.kick(-0.8, 0.5)


## II.4: entregar el mensaje del paso antes de reclutar.
func _setup_arrival() -> void:
	var instance: Node = (load(CAMP_SCENE) as PackedScene).instantiate()
	var point: CampPoint = instance as CampPoint
	var body: Node3D = instance as Node3D
	if point == null or body == null:
		instance.free()
		return
	point.name = "ArrivalPoint"
	point.prompt_key = &"PCH_CIUDAD_TALK_MESSAGE"
	body.position = ARRIVAL_POSITION
	add_child(point)
	_arrival_point = point
	point.set_available(not CampaignState.has_flag(&"mensaje_entregado"))
	point.requested.connect(_on_arrival_requested)


func _on_arrival_requested() -> void:
	if dialogue == null or _defense_active or _completed or _dead:
		return
	if dialogue.is_active():
		return
	if CampaignState.has_flag(&"mensaje_entregado"):
		hud.show_subtitle(tr("PCH_CIUDAD_MESSAGE_AGAIN"), 0.0)
		return
	if dialogue.start(_build_arrival_dialogue()):
		player.begin_dialogue(_cusi_visual)


func _build_arrival_dialogue() -> DialogueGraph:
	var graph: DialogueGraph = DialogueGraph.new()
	graph.entry_id = &"start"
	var start: DialogueNode = DialogueNode.new()
	start.id = &"start"
	start.speaker_key = &"PCH_NPC_CUSI"
	start.text_key = &"PCH_CIUDAD_MESSAGE_INTRO"
	start.next_id = &"end"
	var deliver: DialogueChoice = DialogueChoice.new()
	deliver.text_key = &"PCH_CIUDAD_MESSAGE_DELIVER"
	deliver.next_id = &"answer"
	var leave: DialogueChoice = DialogueChoice.new()
	leave.text_key = &"PCH_DLG_LEAVE"
	leave.next_id = &"end"
	var choices: Array[DialogueChoice] = [deliver, leave]
	start.choices = choices
	var answer: DialogueNode = DialogueNode.new()
	answer.id = &"answer"
	answer.speaker_key = &"PCH_NPC_CUSI"
	answer.text_key = &"PCH_CIUDAD_MESSAGE_ANSWER"
	answer.next_id = &"end"
	var effect: DialogueEffect = DialogueEffect.new()
	effect.kind = DialogueEffect.Kind.SET_FLAG
	effect.key = &"mensaje_entregado"
	effect.amount = 1
	var reputation: DialogueEffect = DialogueEffect.new()
	reputation.kind = DialogueEffect.Kind.REPUTATION
	reputation.group = &"cusco"
	reputation.amount = 1
	var effects: Array[DialogueEffect] = [effect, reputation]
	answer.effects = effects
	var nodes: Array[DialogueNode] = [start, answer]
	graph.nodes = nodes
	return graph


## II.5: cada oficio abre una preparación distinta.
func _setup_preparation() -> void:
	for index: int in range(PREP_POSITIONS.size()):
		var instance: Node = (load(CAMP_SCENE) as PackedScene).instantiate()
		var point: CampPoint = instance as CampPoint
		var body: Node3D = instance as Node3D
		if point == null or body == null:
			instance.free()
			continue
		point.name = "Prep%d" % index
		point.prompt_key = PREP_PROMPTS[index]
		body.position = PREP_POSITIONS[index]
		add_child(point)
		var prop: Node3D = _build_prep_prop(index, PREP_POSITIONS[index])
		point.highlight_target = prop
		_prep_points.append(point)
		point.requested.connect(_on_prep_requested.bind(index))


func _on_prep_requested(index: int) -> void:
	if _defense_active or _completed or _dead:
		return
	if CampaignState.has_flag(&"preparacion_hecha"):
		hud.show_subtitle(tr("PCH_PREP_ALREADY"), 0.0)
		return
	if not CampaignState.has_flag(&"mensaje_entregado"):
		hud.show_subtitle(tr("PCH_PREP_FIRST"), 0.0)
		return
	var oficio: StringName = CampaignProgress.get_oficio()
	if oficio == &"" or oficio != PREP_OFICIOS[index]:
		hud.show_subtitle(tr("PCH_PREP_NO_OFICIO"), 0.0)
		return
	CampaignState.set_flag(&"preparacion_hecha", 1)
	CampaignState.set_flag(StringName("preparacion_" + String(oficio)), 1)
	if character != null:
		character.change_morale(10.0)
		character.register_skill_use(&"oficio", 2)
	SessionLog.mark(&"preparation", String(oficio))
	hud.show_subtitle(tr("PCH_PREP_DONE"), 0.0)
	hud.show_objective(tr("PCH_OBJ_DEFENSE"))


## Puesto de trabajo visible de cada preparación. El oficio decide si responde;
## el prop existe siempre para que el jugador vea qué se hace en cada sitio.
func _build_prep_prop(index: int, at: Vector3) -> Node3D:
	var root: Node3D = Node3D.new()
	root.name = "PrepProp%d" % index
	root.position = Vector3(at.x, _height_at(at.x, at.z), at.z)
	add_child(root)
	var stone: ShaderMaterial = SurfaceMaterials.layer_material(
		SurfaceMaterials.Layer.ROCK, Color(0.52, 0.50, 0.47, 1.0))
	var wood: ShaderMaterial = SurfaceMaterials.layer_material(
		SurfaceMaterials.Layer.WOOD, Color(0.38, 0.27, 0.18, 1.0))
	var fabric: ShaderMaterial = SurfaceMaterials.layer_material(
		SurfaceMaterials.Layer.FABRIC, Color(0.52, 0.30, 0.22, 1.0))
	var soil: ShaderMaterial = SurfaceMaterials.layer_material(
		SurfaceMaterials.Layer.SOIL, Color(0.45, 0.34, 0.22, 1.0))
	match index:
		0:
			_add_block(root, "WallWest", Vector3(-0.8, 0.5, 0.0),
				Vector3(1.0, 1.0, 0.45), stone, false)
			_add_block(root, "WallEast", Vector3(0.8, 0.5, 0.0),
				Vector3(1.0, 1.0, 0.45), stone, false)
			_add_block(root, "LooseStone", Vector3(0.0, 0.15, 0.7),
				Vector3(0.35, 0.3, 0.35), stone, false)
		1:
			_add_block(root, "Metate", Vector3(0.0, 0.18, 0.0),
				Vector3(0.9, 0.16, 0.5), stone, false)
			_add_block(root, "HandStone", Vector3(0.15, 0.32, 0.0),
				Vector3(0.35, 0.18, 0.22), stone, false)
			_add_cylinder_prop(root, "Basket", Vector3(-0.6, 0.2, 0.15),
				0.22, 0.4, soil)
		2:
			_add_model_prop(root, "JarWest", MODEL_PROP_JAR,
				Vector3(-0.45, 0.0, 0.15), 0.4)
			_add_model_prop(root, "JarEast", MODEL_PROP_JAR,
				Vector3(0.45, 0.0, 0.1), -0.6)
			_add_cylinder_prop(root, "Basin", Vector3(0.0, 0.12, -0.55),
				0.45, 0.24, stone)
		_:
			_add_block(root, "Table", Vector3(0.0, 0.35, 0.0),
				Vector3(0.9, 0.7, 0.5), wood, false)
			_add_block(root, "Cloth", Vector3(0.0, 0.72, 0.05),
				Vector3(0.75, 0.04, 0.4), fabric, false)
			_add_block(root, "Frame", Vector3(0.0, 0.55, -0.2),
				Vector3(0.9, 0.05, 0.05), wood, false)
	return root


func _add_cylinder_prop(
	parent: Node3D,
	node_name: String,
	at: Vector3,
	radius: float,
	height: float,
	material: Material
) -> MeshInstance3D:
	var mesh_instance: MeshInstance3D = MeshInstance3D.new()
	mesh_instance.name = node_name
	var cylinder: CylinderMesh = CylinderMesh.new()
	cylinder.top_radius = radius
	cylinder.bottom_radius = radius
	cylinder.height = height
	cylinder.radial_segments = 12
	mesh_instance.mesh = cylinder
	mesh_instance.material_override = material
	mesh_instance.position = at
	parent.add_child(mesh_instance)
	return mesh_instance


## III.2: el santuario o la orden; no se puede hacer todo.
func _setup_trap() -> void:
	var instance: Node = (load(CAMP_SCENE) as PackedScene).instantiate()
	var point: CampPoint = instance as CampPoint
	var body: Node3D = instance as Node3D
	if point == null or body == null:
		instance.free()
		return
	point.name = "TrapPoint"
	point.prompt_key = &"PCH_CIUDAD_TRAP"
	body.position = TRAP_POSITION
	add_child(point)
	_trap_point = point
	_trap_visual = _add_visual_npc(
		Vector3(TRAP_POSITION.x, 0.0, TRAP_POSITION.z), &"curaca", 0)
	point.highlight_target = _trap_visual
	point.requested.connect(_on_trap_requested)


func _on_trap_requested() -> void:
	if dialogue == null or _defense_active or _completed or _dead:
		return
	if dialogue.is_active():
		return
	if _trap_resolved:
		hud.show_subtitle(tr("PCH_CIUDAD_TRAP_AGAIN"), 0.0)
		return
	if dialogue.start(_build_trap_dialogue()):
		player.begin_dialogue(_trap_visual)


func _build_trap_dialogue() -> DialogueGraph:
	var graph: DialogueGraph = DialogueGraph.new()
	graph.entry_id = &"start"
	var start: DialogueNode = DialogueNode.new()
	start.id = &"start"
	start.speaker_key = &"PCH_NPC_CURACA_VECINO"
	start.text_key = &"PCH_CIUDAD_TRAP_INTRO"
	start.next_id = &"end"
	var protect: DialogueChoice = DialogueChoice.new()
	protect.text_key = &"PCH_CIUDAD_TRAP_PROTECT"
	protect.next_id = &"protect"
	var order: DialogueChoice = DialogueChoice.new()
	order.text_key = &"PCH_CIUDAD_TRAP_ORDER"
	order.next_id = &"order"
	var choices: Array[DialogueChoice] = [protect, order]
	start.choices = choices
	var nodes: Array[DialogueNode] = [start]
	for entry: Array in [[&"protect", &"PCH_CIUDAD_TRAP_PROTECT_ANSWER", &"santuario_protegido"],
			[&"order", &"PCH_CIUDAD_TRAP_ORDER_ANSWER", &"orden_llevada"]]:
		var node: DialogueNode = DialogueNode.new()
		node.id = entry[0]
		node.speaker_key = &"PCH_NPC_CURACA_VECINO"
		node.text_key = entry[1]
		node.next_id = &"end"
		var effect: DialogueEffect = DialogueEffect.new()
		effect.kind = DialogueEffect.Kind.SET_FLAG
		effect.key = entry[2]
		effect.amount = 1
		var trap_effect: DialogueEffect = DialogueEffect.new()
		trap_effect.kind = DialogueEffect.Kind.SET_FLAG
		trap_effect.key = &"trampa_resuelta"
		trap_effect.amount = 1
		var effects: Array[DialogueEffect] = [effect, trap_effect]
		node.effects = effects
		nodes.append(node)
	graph.nodes = nodes
	return graph


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
		_recruit_points.append(point)
		point.requested.connect(_on_recruit_requested.bind(index))
		var visual: CharacterModelVisual = _add_visual_npc(
			Vector3(RECRUIT_POSITIONS[index].x, 0.0, RECRUIT_POSITIONS[index].z),
			RECRUIT_ROLES[index], index)
		point.highlight_target = visual
		_recruit_visuals.append(visual)


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
	_cusi_point = point
	point.requested.connect(_on_cusi_requested)
	var delivered: bool = CampaignState.has_flag(&"mensaje_entregado")
	var cusi_at: Vector3 = CUSI_POSITION if delivered else ARRIVAL_POSITION
	_cusi_visual = _add_visual_npc(
		Vector3(cusi_at.x, 0.0, cusi_at.z), &"curaca", 0)
	point.highlight_target = _cusi_visual
	point.set_available(delivered)
	if _arrival_point != null:
		_arrival_point.highlight_target = _cusi_visual


## Diario del acto III: guarda la leyenda de los pururaucas como Memoria.
func _setup_journal() -> void:
	journal = Journal.new()
	journal.name = "Journal"
	player.add_child(journal)
	hud.journal_closed.connect(_on_journal_closed)
	journal.add_quest(&"defensa", &"PCH_Q_DEFENSA_TITLE", &"PCH_Q_DEFENSA_BODY")
	var oficio: StringName = CampaignProgress.get_oficio()
	if oficio != &"" and not journal.has(&"oficio"):
		journal.add_quest(&"oficio", &"PCH_Q_OFICIO_TITLE",
			CampaignProgress.oficio_body_key(oficio))


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
	_vespera_point = point
	point.requested.connect(_on_vespera_requested)
	_vespera_visual = _add_visual_npc(
		Vector3(VESPERA_POSITION.x, 0.0, VESPERA_POSITION.z), &"villager", 2)
	point.highlight_target = _vespera_visual


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
		player.begin_dialogue(_vespera_visual)


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
	var offer: DialogueChoice = DialogueChoice.new()
	offer.text_key = &"PCH_VESPERA_OFFER"
	offer.next_id = &"offer"
	var offer_condition: DialogueCondition = DialogueCondition.new()
	offer_condition.kind = DialogueCondition.Kind.ITEM
	offer_condition.key = &"coca"
	offer_condition.minimum = 1
	var offer_conditions: Array[DialogueCondition] = [offer_condition]
	offer.conditions = offer_conditions
	var sleep: DialogueChoice = DialogueChoice.new()
	sleep.text_key = &"PCH_VESPERA_SLEEP"
	sleep.next_id = &"sleep"
	var leave: DialogueChoice = DialogueChoice.new()
	leave.text_key = &"PCH_DLG_LEAVE"
	leave.next_id = &"end"
	var choices: Array[DialogueChoice] = [listen, offer, sleep, leave]
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
	var offer_node: DialogueNode = DialogueNode.new()
	offer_node.id = &"offer"
	offer_node.speaker_key = &"PCH_NPC_ELDER"
	offer_node.text_key = &"PCH_VESPERA_OFFER_DONE"
	offer_node.next_id = &"end"
	var offer_effect: DialogueEffect = DialogueEffect.new()
	offer_effect.kind = DialogueEffect.Kind.ITEM_REMOVE
	offer_effect.key = &"coca"
	offer_effect.amount = 1
	var offer_flag: DialogueEffect = DialogueEffect.new()
	offer_flag.kind = DialogueEffect.Kind.SET_FLAG
	offer_flag.key = &"ofrenda_hecha"
	offer_flag.amount = 1
	var offer_effects: Array[DialogueEffect] = [offer_effect, offer_flag]
	offer_node.effects = offer_effects
	var sleep_node: DialogueNode = DialogueNode.new()
	sleep_node.id = &"sleep"
	sleep_node.speaker_key = &"PCH_NPC_ELDER"
	sleep_node.text_key = &"PCH_VESPERA_SLEEP_DONE"
	sleep_node.next_id = &"end"
	var sleep_effect: DialogueEffect = DialogueEffect.new()
	sleep_effect.kind = DialogueEffect.Kind.SET_FLAG
	sleep_effect.key = &"descanso_cusco"
	sleep_effect.amount = 1
	var sleep_effects: Array[DialogueEffect] = [sleep_effect]
	sleep_node.effects = sleep_effects
	var nodes: Array[DialogueNode] = [start, tale, close, offer_node, sleep_node]
	graph.nodes = nodes
	return graph


func _on_journal_closed() -> void:
	player.set_controls_locked(false)


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
	SessionLog.mark(&"recruit", "%d:%s" % [index, "si" if joins else "no"])
	var graph: DialogueGraph = _build_recruit_dialogue(index, joins)
	if dialogue.start(graph):
		var target: Node3D = null
		if index >= 0 and index < _recruit_visuals.size():
			target = _recruit_visuals[index]
		player.begin_dialogue(target)


func _on_cusi_requested() -> void:
	if _defense_active or _completed or _dead or dialogue == null:
		return
	if dialogue.is_active():
		return
	var graph: DialogueGraph = _build_cusi_dialogue()
	if dialogue.start(graph):
		player.begin_dialogue(_cusi_visual)


func _recruit_joins(index: int) -> bool:
	var cusco_reputation: int = character.get_reputation(&"cusco") if character != null else 0
	var word: int = character.get_skill(&"palabra") if character != null else 0
	match index:
		0:
			return CampaignState.has_flag(&"maiz_guardado") or cusco_reputation >= 1
		1:
			return (CampaignState.has_flag(&"mensaje_chanca") or word >= 2) and cusco_reputation >= 1
		2:
			return CampaignState.get_flag(&"confianza_sisa") >= 1
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
		if index == 1 and character != null:
			character.register_skill_use(&"palabra", 2)
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
	_cost_applied = false
	_wave = 1
	_disable_interactions_for_defense()
	if CampaignState.has_flag(&"herido_salvado"):
		_anca_visual = _add_visual_npc(Vector3(-3.0, 0.0, -8.0), &"villager", 1)
	elif CampaignState.has_flag(&"aliado_2") and ally_count() < 2:
		_young_visual = _add_visual_npc(Vector3(3.0, 0.0, -8.0), &"villager", 2)
	CampaignProgress.save_checkpoint(self, player.global_position)
	_start_drum()
	_retreat_crowd()
	_play_gesture(_cusi_visual, &"talk")
	SessionLog.mark(&"defense_start", "aliados=%d" % ally_count())
	_spawn_wave()
	hud.show_subtitle(tr("PCH_CIUDAD_DEFENSE"), 0.0)
	hud.show_objective(tr("PCH_OBJ_HOLD"))
	_update_status()


## Durante la defensa no se ofrecen preparaciones, reclutas ni la trampa: sus
## manejadores ya la rechazan, pero el HUD no debe mostrar una acción muerta.
func _disable_interactions_for_defense() -> void:
	for point: CampPoint in _prep_points:
		point.set_available(false)
	for point: CampPoint in _recruit_points:
		point.set_available(false)
	if _trap_point != null:
		_trap_point.set_available(false)
	if _vespera_point != null:
		_vespera_point.set_available(false)
	if _cusi_point != null:
		_cusi_point.set_available(false)


## Cada oleada trae menos enemigos si el jugador reclutó y preparó la defensa.
func _spawn_wave() -> void:
	if _director == null:
		_director = EncounterDirector.new()
		_director.name = "EncounterDirector"
		_director.max_attackers = 2
		add_child(_director)
	var prepared: int = 1 if CampaignState.has_flag(&"preparacion_hecha") else 0
	# Cruzar el paso con la columna evita un enemigo en la primera oleada; si
	# la bandera falta (partida de prueba), la plaza trae uno más.
	var crossed: int = 1 if CampaignState.has_flag(&"paso_cruzado") else 0
	var count: int = maxi(1, 5 - ally_count() - prepared - crossed - (_wave - 1))
	for index: int in range(count):
		var enemy: AmbushEnemy = AmbushEnemy.new()
		enemy.name = "Defender%d_%d" % [_wave, index + 1]
		enemy.position = DEFENSE_POSITIONS[index % DEFENSE_POSITIONS.size()]
		add_child(enemy)
		enemy.setup(player, self)
		enemy.director = _director
		_director.register(enemy)
		_enemies.append(enemy)


## La multitud deja la plaza cuando empieza la defensa y se refugia junto a las
## casas. No participa en el combate; solo da vida al cambio de la ciudad.
func _retreat_crowd() -> void:
	if _crowd.is_empty():
		return
	_crowd_retreating = true
	for member: CrowdMember in _crowd:
		member.retreating = true
		# La multitud huye: el ciclo se ajusta a la velocidad real de la huida.
		member.visual.play_locomotion(CROWD_RETREAT_SPEED)


func _update_crowd(delta: float) -> void:
	var remaining: bool = false
	for index: int in range(_crowd.size()):
		var member: CrowdMember = _crowd[index]
		if member.retreating:
			remaining = true
			_update_crowd_retreat(member, delta)
			continue
		if _defense_active:
			continue
		_update_crowd_member(index, member, delta)
	if not remaining and _crowd_retreating:
		_crowd_retreating = false


## Retirada al refugio cuando empieza la defensa.
func _update_crowd_retreat(member: CrowdMember, delta: float) -> void:
	var target: Vector3 = Vector3(
		member.safe_position.x,
		member.visual.position.y,
		member.safe_position.z)
	var distance: float = member.visual.position.distance_to(target)
	if distance <= 0.2:
		member.retreating = false
		member.speed = 0.0
		member.visual.play(&"Idle")
		var center: Vector3 = Vector3(0.0, member.visual.position.y, 0.0)
		if member.visual.position.distance_to(center) > 0.1:
			member.visual.look_at(center, Vector3.UP)
		return
	member.visual.position = member.visual.position.move_toward(target, CROWD_RETREAT_SPEED * delta)
	member.speed = CROWD_RETREAT_SPEED
	member.visual.play_locomotion(CROWD_RETREAT_SPEED)
	var flat_target: Vector3 = Vector3(target.x, member.visual.position.y, target.z)
	if member.visual.position.distance_to(flat_target) > 0.1:
		member.visual.look_at(flat_target, Vector3.UP)


## Rutina de una figura: pareja que conversa, puesto atendido, paseo corto o
## descanso junto a la plaza. La reacción al jugador interrumpe el paseo, no la
## conversación de una pareja.
func _update_crowd_member(index: int, member: CrowdMember, delta: float) -> void:
	var visual: CharacterModelVisual = member.visual
	var to_player: Vector3 = player.global_position - visual.global_position
	to_player.y = 0.0
	var player_distance: float = to_player.length()
	member.react_cooldown = maxf(member.react_cooldown - delta, 0.0)
	if member.reacting_left > 0.0:
		member.reacting_left -= delta
		member.speed = 0.0
		if player_distance > 0.05:
			var react_yaw: float = atan2(-to_player.x, -to_player.z)
			visual.rotation.y = lerp_angle(visual.rotation.y, react_yaw, CROWD_LOOK_SPEED * delta)
		_play_if_needed(visual, &"idle_b")
		return
	if member.pair >= 0 and member.pair < _crowd.size():
		_update_crowd_pair(member, delta)
		return
	if CROWD_VENDORS.has(index):
		_update_crowd_vendor(member, player_distance, to_player, delta)
		return
	# Un paseante se detiene y mira al jugador cuando pasa cerca; luego sigue.
	if not member.route.is_empty() and member.react_cooldown <= 0.0 \
			and player_distance < CROWD_REACT_DISTANCE and member.rng.randf() < 0.45:
		member.reacting_left = CROWD_REACT_SECONDS
		member.react_cooldown = CROWD_REACT_SECONDS + 8.0
		member.pause_left = maxf(member.pause_left, 1.0)
		return
	if member.pause_left > 0.0:
		member.pause_left -= delta
		member.speed = 0.0
		_play_if_needed(visual, member.activity)
		if member.pause_left <= 0.0:
			member.activity_left = member.rng.randf_range(CROWD_ACTIVITY_MIN, CROWD_ACTIVITY_MAX)
		return
	if member.route.is_empty():
		_face_rest_point(member, player_distance, to_player, delta)
		_cycle_activity(member, delta)
		return
	var target: Vector3 = member.route[member.route_index]
	var to_target: Vector3 = target - visual.position
	to_target.y = 0.0
	var distance: float = to_target.length()
	if distance < 0.22:
		member.route_index = (member.route_index + 1) % member.route.size()
		member.pause_left = member.rng.randf_range(CROWD_PAUSE_MIN, CROWD_PAUSE_MAX)
		member.activity = CROWD_ACTIVITIES[index % CROWD_ACTIVITIES.size()]
		member.activity_left = member.rng.randf_range(CROWD_ACTIVITY_MIN, CROWD_ACTIVITY_MAX)
		visual.play(member.activity)
		return
	var step: float = minf(CROWD_WALK_SPEED * delta, distance)
	visual.position += to_target.normalized() * step
	member.speed = step / maxf(delta, 0.001)
	var travel_yaw: float = atan2(-to_target.x, -to_target.z)
	visual.rotation.y = lerp_angle(visual.rotation.y, travel_yaw, CROWD_LOOK_SPEED * delta)
	visual.play_locomotion(member.speed)


## Pareja que conversa: se miran, alternan gesto y reposo.
func _update_crowd_pair(member: CrowdMember, delta: float) -> void:
	var other: CharacterModelVisual = _crowd[member.pair].visual
	var to_other: Vector3 = other.global_position - member.visual.global_position
	to_other.y = 0.0
	if to_other.length() > 0.1:
		var yaw: float = atan2(-to_other.x, -to_other.z)
		member.visual.rotation.y = lerp_angle(member.visual.rotation.y, yaw, CROWD_LOOK_SPEED * delta)
	member.speed = 0.0
	member.activity_left -= delta
	if member.activity_left <= 0.0:
		member.activity = &"idle_b" if member.activity == &"talk" else &"talk"
		member.activity_left = member.rng.randf_range(4.0, 7.0)
		member.visual.play(member.activity)


## Puesto atendido: mira al jugador si se acerca y alterna gesto de trato con
## reposo. La mercancía y el mostrador ya están en la plaza.
func _update_crowd_vendor(
	member: CrowdMember,
	player_distance: float,
	to_player: Vector3,
	delta: float
) -> void:
	member.speed = 0.0
	var desired: float = member.home_yaw
	if player_distance < 6.0 and player_distance > 0.05:
		desired = atan2(-to_player.x, -to_player.z)
	member.visual.rotation.y = lerp_angle(member.visual.rotation.y, desired, CROWD_LOOK_SPEED * delta)
	member.activity_left -= delta
	if member.activity_left <= 0.0:
		member.activity = &"idle_b" if member.activity == &"talk" else &"talk"
		member.activity_left = member.rng.randf_range(5.0, 9.0)
		member.visual.play(member.activity)


func _face_rest_point(member: CrowdMember, player_distance: float, to_player: Vector3, delta: float) -> void:
	var desired: float = member.home_yaw
	if player_distance < CROWD_LOOK_DISTANCE and player_distance > 0.05:
		desired = atan2(-to_player.x, -to_player.z)
	member.visual.rotation.y = lerp_angle(member.visual.rotation.y, desired, CROWD_LOOK_SPEED * delta)
	_cycle_activity(member, delta)


func _cycle_activity(member: CrowdMember, delta: float) -> void:
	member.speed = 0.0
	member.activity_left -= delta
	if member.activity_left > 0.0:
		return
	member.activity = &"idle_b" if member.activity == &"talk" else &"talk"
	member.activity_left = member.rng.randf_range(CROWD_ACTIVITY_MIN, CROWD_ACTIVITY_MAX)
	member.visual.play(member.activity)


## Cambia el clip solo cuando hace falta, para no reiniciar el gesto cada tick.
func _play_if_needed(visual: CharacterModelVisual, clip: StringName) -> void:
	if visual.current_animation() != clip:
		visual.play(clip)


## El costo se ve: el defensor con nombre cae en la plaza mientras se compone
## el epílogo. La tarjeta lo recuerda; la animación lo muestra.
func _play_cost_fall(visual: CharacterModelVisual, text_key: StringName) -> void:
	if visual != null:
		visual.play(&"death")
	if hud != null:
		hud.show_subtitle(tr(String(text_key)), 0.0)
	SessionLog.mark(&"cost_fall", String(text_key))


## El coste con nombre se decide al llegar la última oleada. La tarjeta del
## epílogo lo recuerda, pero la caída ya se vio en la plaza.
func _apply_defense_cost() -> void:
	if _cost_applied:
		return
	_cost_applied = true
	if CampaignState.has_flag(&"herido_salvado"):
		CampaignState.set_flag(&"costo_anca", 1)
		_play_cost_fall(_anca_visual, &"PCH_CIUDAD_COST_ANCA")
	elif CampaignState.has_flag(&"aliado_2") and ally_count() < 2:
		CampaignState.set_flag(&"costo_joven", 1)
		_play_cost_fall(_young_visual, &"PCH_CIUDAD_COST_JOVEN")
	else:
		CampaignState.set_flag(&"sin_costo", 1)
	if character != null and (CampaignState.has_flag(&"costo_anca") or CampaignState.has_flag(&"costo_joven")):
		character.change_morale(-15.0)


func _finish_defense() -> void:
	if _completed:
		return
	_completed = true
	_defense_active = false
	_stop_drum()
	_apply_defense_cost()
	var epilogue: String = tr("PCH_CIUDAD_COUNTER") + " " + tr("PCH_CIUDAD_EPILOGUE")
	if CampaignState.has_flag(&"costo_anca"):
		epilogue += " " + tr("PCH_CIUDAD_COST_ANCA")
	elif CampaignState.has_flag(&"costo_joven"):
		epilogue += " " + tr("PCH_CIUDAD_COST_JOVEN")
	else:
		epilogue += " " + tr("PCH_CIUDAD_NO_COST")
	if CampaignState.has_flag(&"santuario_protegido"):
		epilogue += " " + tr("PCH_CIUDAD_EPILOGUE_SANCTUARY")
	elif CampaignState.has_flag(&"orden_llevada"):
		epilogue += " " + tr("PCH_CIUDAD_EPILOGUE_ORDER")
	if CampaignState.has_flag(&"maiz_guardado"):
		epilogue += " " + tr("PCH_CIUDAD_EPILOGUE_MAIZE")
	if CampaignState.has_flag(&"scout_spared"):
		epilogue += " " + tr("PCH_CIUDAD_EPILOGUE_SPARED")
	if journal != null:
		journal.complete_quest(&"defensa")
		journal.add_memory(&"mem_cusco", &"PCH_ST_CUSCO_TITLE", &"PCH_ST_CUSCO_BODY", &"A", &"PCH_ST_CUSCO_SOURCE")
	CampaignProgress.save(self)
	hud.show_end_card(tr("PCH_CIUDAD_END_TITLE"), tr("PCH_CIUDAD_END_HINT"), epilogue)
	SessionLog.mark(&"defense_end", "salud=%d aliados=%d" % [int(character.get_health()), ally_count()])


## E, Intro o R continúan desde la tarjeta de fin.
static func _advance_requested(event: InputEvent) -> bool:
	if event.is_action_pressed("interact"):
		return true
	if not (event is InputEventKey):
		return false
	var key: InputEventKey = event as InputEventKey
	if not key.pressed or key.echo:
		return false
	return key.keycode == KEY_R or key.keycode == KEY_ENTER or key.keycode == KEY_KP_ENTER


## Solo R reintenta tras caer.
static func _retry_requested(event: InputEvent) -> bool:
	if not (event is InputEventKey):
		return false
	var key: InputEventKey = event as InputEventKey
	return key.pressed and not key.echo and key.keycode == KEY_R


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
	if hud == null:
		return
	hud.set_status("")


func _restore_allies() -> void:
	for index: int in range(3):
		if CampaignState.has_flag(_ally_key(index)):
			_add_ally_visual(index)


## Modelo MakeHuman/Rocketbox para un rol y una variante de color.
func _character_model_for(role: StringName, variant: int) -> String:
	match role:
		&"curaca":
			return "pch_npc_curaca.glb"
		&"principal":
			return "pch_npc_principal.glb"
		&"farmer":
			return "pch_npc_farmer.glb"
		&"messenger":
			return "pch_npc_messenger.glb"
		&"weaver":
			return "pch_npc_weaver.glb"
	match variant % 3:
		1:
			return "pch_npc_villager_b.glb"
		2:
			return "pch_npc_villager_c.glb"
	return "pch_npc_villager.glb"


func _add_visual_npc(at: Vector3, role: StringName, variant: int) -> CharacterModelVisual:
	var visual: CharacterModelVisual = CharacterModelVisual.new()
	visual.name = "Visual"
	visual.model_path = MODEL_DIR + CharacterCatalog.model_for(String(role), _character_model_for(role, variant))
	visual.position = at
	add_child(visual)
	visual.look_at(Vector3(0.0, at.y, 28.0), Vector3.UP)
	_idle_visual_home[visual] = visual.rotation.y
	return visual


## Gira despacio a Cusi, los reclutas y los aliados hacia el jugador cuando se
## acerca; al alejarse recuperan su orientación de reposo. No es una mirada de
## hueso (esos modelos no la traen), pero rompe la sensación de estatua.
func _update_idle_visuals(delta: float) -> void:
	for visual: CharacterModelVisual in _idle_visual_home:
		if not is_instance_valid(visual):
			continue
		var to_player: Vector3 = player.global_position - visual.global_position
		to_player.y = 0.0
		var desired: float = _idle_visual_home[visual]
		if to_player.length() < CROWD_LOOK_DISTANCE and to_player.length() > 0.05:
			desired = atan2(-to_player.x, -to_player.z)
		visual.rotation.y = lerp_angle(visual.rotation.y, desired, CROWD_LOOK_SPEED * delta)


## Gesto puntual de un personaje (Cusi al arengar) y vuelta al reposo cuando el
## clip termina. No bloquea la escena ni el diálogo.
func _play_gesture(visual: CharacterModelVisual, clip: StringName) -> void:
	if visual == null:
		return
	var seconds: float = visual.clip_length(clip)
	if seconds <= 0.0:
		return
	visual.play(clip)
	get_tree().create_timer(seconds).timeout.connect(func() -> void:
		if is_instance_valid(visual):
			visual.play(&"Idle"))


func _add_ally_visual(index: int) -> void:
	if _ally_visuals.has(index):
		return
	_ally_visuals[index] = true
	var visual: CharacterModelVisual = CharacterModelVisual.new()
	visual.name = "Ally%d" % index
	visual.model_path = MODEL_DIR + _character_model_for(&"villager", index)
	visual.position = ALLY_POSITIONS[index]
	add_child(visual)
	visual.look_at(Vector3(0.0, ALLY_POSITIONS[index].y, 28.0), Vector3.UP)
	_idle_visual_home[visual] = visual.rotation.y


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
	if _cusi_move_pending:
		_cusi_move_pending = false
		_move_cusi_to_sanctuary()
	if _defense_requested:
		_defense_requested = false
		if not _can_start_defense():
			hud.show_subtitle(tr("PCH_CIUDAD_TRAP_FIRST"), 0.0)
			hud.show_objective(tr("PCH_CIUDAD_TRAP"))
			return
		_start_defense()


## La trampa es una decisión previa: no se puede empezar la defensa sin ella.
func _can_start_defense() -> bool:
	return CampaignState.has_flag(&"trampa_resuelta")


## Cusi recibe el mensaje en la puerta y luego vuelve al santuario. Así la
## llegada tiene un interlocutor visible y el santuario no queda vacío.
func _move_cusi_to_sanctuary() -> void:
	if _cusi_visual != null:
		_cusi_visual.global_position = Vector3(CUSI_POSITION.x, 0.0, CUSI_POSITION.z)
		_cusi_visual.look_at(Vector3(0.0, 0.0, 28.0), Vector3.UP)
	if _arrival_point != null:
		_arrival_point.set_available(false)
	if _cusi_point != null:
		_cusi_point.set_available(true)


func _on_dialogue_flag(key: StringName, value: int) -> void:
	CampaignState.set_flag(key, value)
	if key == &"defensa_iniciada" and value != 0:
		_defense_requested = true
		return
	if key == &"mensaje_entregado" and value != 0:
		# Cusi se mueve al santuario cuando la conversación termina: moverlo
		# mientras la cámara lo enfoca daría un salto visible.
		_cusi_move_pending = true
		hud.show_objective(tr("PCH_OBJ_RECRUIT"))
		return
	if key == &"preparacion_hecha" and value != 0:
		hud.show_objective(tr("PCH_OBJ_DEFENSE"))
		return
	if key == &"trampa_resuelta" and value != 0:
		_trap_resolved = true
		return
	if key == &"ofrenda_hecha" and value != 0 and character != null:
		character.change_morale(10.0)
		return
	if key == &"descanso_cusco" and value != 0 and character != null:
		character.heal(15.0)
		if player.stamina != null:
			player.stamina.restore(20.0)
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
	player_combatant = Combatant.new()
	player_combatant.name = "PlayerCombatant"
	player_combatant.character = character
	player_combatant.stamina = player.stamina
	player.add_child(player_combatant)
	loadout = CombatLoadout.new()
	loadout.name = "CombatLoadout"
	loadout.character = character
	loadout.stamina = player.stamina
	loadout.combatant = player_combatant
	player.add_child(loadout)
	loadout.weapon_changed.connect(_on_weapon_changed)
	loadout.ammo_changed.connect(_on_ammo_changed)
	loadout.blocking_changed.connect(_on_blocking_changed)
	loadout.attack_started.connect(_on_attack_started)
	loadout.attack_active.connect(_on_attack_active)
	loadout.parried.connect(_on_parried)
	loadout.blocked.connect(_on_blocked)
	_hit_stop = HitStop.new()
	_hit_stop.name = "HitStop"
	add_child(_hit_stop)
	_camera_kick = player.get_node_or_null("Head/CameraKick") as CameraKick
	if not CampaignState.has_data(&"stones"):
		CampaignState.set_data(&"stones", CombatLoadout.DEFAULT_STONES)
	var raw_stones: Variant = CampaignState.get_data(&"stones", CombatLoadout.DEFAULT_STONES)
	var stones: int = CombatLoadout.DEFAULT_STONES
	if raw_stones is int:
		stones = raw_stones
	loadout.set_ammo(stones)
	var camera: Camera3D = player.get_node_or_null("Head/Camera3D") as Camera3D
	if camera != null:
		_attack_ray = RayCast3D.new()
		_attack_ray.name = "AttackRay"
		_attack_ray.target_position = Vector3(0.0, 0.0, -30.0)
		_attack_ray.collision_mask = 9
		_attack_ray.enabled = true
		camera.add_child(_attack_ray)
	_refresh_weapon_visual(loadout.current_weapon())
	_on_ammo_changed(loadout.ammo())


func _on_weapon_changed(_index: int, weapon: CombatWeapon) -> void:
	_refresh_weapon_visual(weapon)
	_on_ammo_changed(loadout.ammo())


func _sync_loadout_ammo() -> void:
	if loadout == null:
		return
	var raw: Variant = CampaignState.get_data(&"stones", CombatLoadout.DEFAULT_STONES)
	var stones: int = CombatLoadout.DEFAULT_STONES
	if raw is int:
		stones = raw
	loadout.set_ammo(stones)


func _on_ammo_changed(remaining: int) -> void:
	CampaignState.set_data(&"stones", remaining)
	if hud != null and loadout != null:
		hud.set_ammo(remaining, loadout.is_ranged())


func _on_blocking_changed(blocking: bool) -> void:
	var visual: FirstPersonWeapon = player.get_node_or_null("Head/Camera3D/FirstPersonWeapon") as FirstPersonWeapon
	if visual != null:
		visual.set_blocking(blocking)


func _refresh_weapon_visual(weapon: CombatWeapon) -> void:
	var visual: FirstPersonWeapon = player.get_node_or_null("Head/Camera3D/FirstPersonWeapon") as FirstPersonWeapon
	if visual != null and weapon != null:
		visual.set_weapon(weapon.kind)


func _switch_weapon(index: int) -> void:
	if loadout != null:
		loadout.switch_to(index)


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
	_build_ground_clutter()
	_build_processional_path()
	_build_plaza_areas()
	_build_sanctuary()
	_build_houses()
	_build_walls()
	_build_gate()
	_build_wall_caps()
	_build_plaza_furniture()
	_build_market()
	_build_sanctuary_props()
	_build_vegetation()
	_build_terraces()
	_build_crowd()
	_build_distant_hills()
	_build_clouds()
	_build_dust()


## Cordilleras que cierran el valle. Son siluetas sin colisión ni sombra, con
## el pie desvanecido en bruma: sin ellas el terreno termina en una línea recta.
func _build_distant_hills() -> void:
	# Bandas con volumen: la más cercana cierra el valle y las otras dan
	# profundidad. Comparten el generador de la llacta.
	var sun_direction: Vector3 = Vector3(0.3, 0.8, 0.5)
	var light: DirectionalLight3D = get_node_or_null("Sun") as DirectionalLight3D
	if light != null:
		sun_direction = light.global_transform.basis.z
	DistantRange.build(self, "HillsNear", 110.0, 200.0, 55.0, 4.0,
		Color(0.32, 0.35, 0.31, 1.0), sun_direction)
	DistantRange.build(self, "HillsMid", 170.0, 280.0, 70.0, 5.0,
		Color(0.31, 0.34, 0.37, 1.0), sun_direction)
	DistantRange.build(self, "HillsFar", 240.0, 380.0, 85.0, 6.0,
		Color(0.36, 0.40, 0.46, 1.0), sun_direction)


## Piedras sueltas: el suelo plano de la plaza se leía como una alfombra.
func _build_ground_clutter() -> void:
	var clutter: GroundClutter = GroundClutter.new()
	clutter.name = "GroundClutter"
	add_child(clutter)
	clutter.build(_height_at, Vector3.ZERO, 72.0, 6.0)


## Camino procesional de la puerta al santuario: lajas planas irregulares, en
## una sola llamada de dibujo. La plaza de tierra necesita una guía visual; sin
## ella el jugador entra a un descampado. Es reconstrucción de ambiente (R).
func _build_processional_path() -> void:
	var surface: MultiMesh = MultiMesh.new()
	surface.transform_format = MultiMesh.TRANSFORM_3D
	surface.use_colors = true
	var cobble: CylinderMesh = CylinderMesh.new()
	cobble.top_radius = 0.23
	cobble.bottom_radius = 0.20
	cobble.height = 0.05
	cobble.radial_segments = 7
	surface.mesh = cobble
	var rng: RandomNumberGenerator = RandomNumberGenerator.new()
	rng.seed = 1438
	var transforms: Array[Transform3D] = []
	var colors: Array[Color] = []
	var rows: Array[float] = [-0.72, 0.0, 0.72]
	for row: float in rows:
		var z: float = -13.2
		while z < 29.5:
			if rng.randf() > 0.16:
				var yaw: float = rng.randf_range(-0.5, 0.5)
				var size: float = rng.randf_range(0.78, 1.18)
				var x: float = row + rng.randf_range(-0.14, 0.14)
				var stone_basis: Basis = Basis(Vector3.UP, yaw).scaled(Vector3(size, 1.0, size))
				transforms.append(Transform3D(stone_basis, Vector3(x, 0.035, z)))
				var shade: float = rng.randf_range(-0.05, 0.05)
				colors.append(Color(0.38 + shade, 0.35 + shade, 0.31 + shade, 1.0))
			z += rng.randf_range(0.52, 0.78)
	surface.instance_count = transforms.size()
	for index: int in range(transforms.size()):
		surface.set_instance_transform(index, transforms[index])
		surface.set_instance_color(index, colors[index])
	var instance: MultiMeshInstance3D = MultiMeshInstance3D.new()
	instance.name = "ProcessionalPath"
	instance.multimesh = surface
	instance.material_override = SurfaceMaterials.layer_material(
		SurfaceMaterials.Layer.STONE, Color(0.56, 0.52, 0.46, 1.0), true)
	instance.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	instance.gi_mode = GeometryInstance3D.GI_MODE_DISABLED
	add_child(instance)


func _build_terrain() -> void:
	var terrain: Node3D = Node3D.new()
	terrain.name = "Terrain"
	add_child(terrain)
	var surface: SurfaceTool = SurfaceTool.new()
	surface.begin(Mesh.PRIMITIVE_TRIANGLES)
	var step: float = CITY_TERRAIN_SIZE / float(TERRAIN_RESOLUTION)
	var half: float = CITY_TERRAIN_SIZE * 0.5
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
	mesh_instance.material_override = SurfaceMaterials.terrain_material(GRASS_COLOR, ROCK_COLOR, DIRT_COLOR)
	# El terreno recibe sombra; su propia sombra no aporta frente a casas y muros.
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


## Cota del terreno. La plaza y el anillo de casas quedan planos; a partir del
## muro el valle ondula y se cierra en lomas. El borde del plano ya no es una
## línea recta en el horizonte.
func _height_at(x: float, z: float) -> float:
	var distance: float = Vector2(x, z).length()
	if distance <= TERRAIN_FLAT_RADIUS:
		return 0.0
	var t: float = smoothstep(TERRAIN_FLAT_RADIUS, 72.0, distance)
	var wave: float = 0.55 * sin(x * 0.045 + 1.1) + 0.35 * cos(z * 0.052 - 0.6) 		+ 0.18 * sin((x - z) * 0.09 + 0.7)
	var rise: float = smoothstep(34.0, 58.0, distance) * 1.05
	var ridge: float = smoothstep(82.0, 145.0, distance) * 2.2
	return rise + wave * 0.55 * t + ridge


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
	var pirca: ShaderMaterial = SurfaceMaterials.layer_material(SurfaceMaterials.Layer.STONE, STONE_TINT, true)
	var thatch: ShaderMaterial = SurfaceMaterials.layer_material(SurfaceMaterials.Layer.THATCH, THATCH_TINT)
	_add_block(sanctuary, "Base", Vector3(0.0, 0.3, -18.0), Vector3(9.0, 0.6, 9.0), stone, true)
	_add_sanctuary_pirca(sanctuary, "BasePirca", Vector3(0.0, 0.0, -18.0), Vector3(9.0, 0.6, 9.0), pirca, 2401)
	_add_block(sanctuary, "StepMiddle", Vector3(0.0, 0.9, -18.0), Vector3(7.0, 0.6, 7.0), stone, true)
	_add_sanctuary_pirca(sanctuary, "MiddlePirca", Vector3(0.0, 0.6, -18.0), Vector3(7.0, 0.6, 7.0), pirca, 2402)
	_add_block(sanctuary, "StepTop", Vector3(0.0, 1.5, -18.0), Vector3(5.0, 0.6, 5.0), stone, true)
	_add_sanctuary_pirca(sanctuary, "TopPirca", Vector3(0.0, 1.2, -18.0), Vector3(5.0, 0.6, 5.0), pirca, 2403)
	_add_block(sanctuary, "Shrine", Vector3(0.0, 2.4, -18.0), Vector3(3.0, 1.2, 3.0), stone, true)
	_add_sanctuary_pirca(sanctuary, "ShrinePirca", Vector3(0.0, 1.8, -18.0), Vector3(3.0, 1.2, 3.0), pirca, 2404)
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


## Reviste una grada del santuario con pirca seca. Los bloques de colisión
## siguen detrás; la cara de piedra evita que la grada parezca hormigón.
func _add_sanctuary_pirca(
	parent: Node3D,
	node_name: String,
	base: Vector3,
	size: Vector3,
	material: Material,
	wall_seed: int
) -> void:
	var half_x: float = size.x * 0.5
	var half_z: float = size.z * 0.5
	var faces: Array[StoneWall.Face] = [
		StoneWall.Face.new(Vector3(base.x - half_x, base.y, base.z + half_z), Vector3.RIGHT, Vector3.BACK, size.x, size.y),
		StoneWall.Face.new(Vector3(base.x + half_x, base.y, base.z - half_z), Vector3.LEFT, Vector3.FORWARD, size.x, size.y),
		StoneWall.Face.new(Vector3(base.x + half_x, base.y, base.z + half_z), Vector3.FORWARD, Vector3.RIGHT, size.z, size.y),
		StoneWall.Face.new(Vector3(base.x - half_x, base.y, base.z - half_z), Vector3.BACK, Vector3.LEFT, size.z, size.y),
	]
	var mesh: MeshInstance3D = MeshInstance3D.new()
	mesh.name = node_name
	mesh.mesh = StoneWall.build(faces, wall_seed)
	mesh.material_override = material
	parent.add_child(mesh)


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
	var tint: Color = HOUSE_TINTS[index % HOUSE_TINTS.size()]
	root.scale = Vector3.ONE * HOUSE_SCALES[index % HOUSE_SCALES.size()]
	var base: Node3D = _add_block(root, "Base", Vector3(0.0, 1.25, 0.0), Vector3(6.0, 2.5, 5.0), stone, true)
	var roof: MeshInstance3D = MeshInstance3D.new()
	roof.name = "Roof"
	roof.position = Vector3(0.0, 3.25, 0.0)
	var prism: PrismMesh = PrismMesh.new()
	prism.size = Vector3(6.6, 1.5, 5.6)
	roof.mesh = prism
	# El techo también varía de tono: dos casas iguales se notan menos si el
	# ichu no es exactamente del mismo color.
	var roof_material: ShaderMaterial = thatch.duplicate() as ShaderMaterial
	roof_material.set_shader_parameter("tint", tint)
	roof.material_override = roof_material
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
	_tint_model(slot.model, tint)
	_add_house_props(root, index)


## Aplica un tinte propio a todas las mallas del modelo sin tocar el material
## compartido del resto de la ciudad.
func _tint_model(model: Node3D, tint: Color) -> void:
	if model == null or tint == Color(1.0, 1.0, 1.0):
		return
	for node: Node in model.find_children("*", "MeshInstance3D", true, false):
		var mesh_instance: MeshInstance3D = node as MeshInstance3D
		var base: ShaderMaterial = mesh_instance.material_override as ShaderMaterial
		if base == null:
			continue
		var material: ShaderMaterial = base.duplicate() as ShaderMaterial
		material.set_shader_parameter("tint", tint)
		mesh_instance.material_override = material


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


## Dos puestos de trueque en la plaza. Son la escala y el punto focal que
## faltaban: el jugador entra por el sur y ve gente y mercancía en el camino.
## La geometría es la misma de las casas (postes de madera, techo de ichu), sin
## modelos nuevos.
func _build_market() -> void:
	var market: Node3D = Node3D.new()
	market.name = "Market"
	add_child(market)
	# Al norte de la plaza: en el eje sur quedaban en medio del camino de
	# entrada y la cámara les pasaba por debajo del techo.
	_add_stall(market, 0, Vector3(-8.5, 0.0, -6.0), 0.35)
	_add_stall(market, 1, Vector3(8.5, 0.0, -6.0), -0.35)
	_add_model_prop(market, "MarketFirewood", MODEL_PROP_FIREWOOD, Vector3(-6.4, 0.0, -4.2), 0.9, 1.0)
	_add_model_prop(market, "MarketJar", MODEL_PROP_JAR, Vector3(6.4, 0.0, -4.4), 0.2, 1.1)


## Puesto de trueque: cuatro postes, techo de ichu y un mostrador con cántaros.
func _add_stall(parent: Node3D, index: int, at: Vector3, yaw: float) -> Node3D:
	var stall: Node3D = Node3D.new()
	stall.name = "Stall%d" % index
	stall.position = at
	stall.rotation.y = yaw
	parent.add_child(stall)
	var wood: ShaderMaterial = SurfaceMaterials.layer_material(
		SurfaceMaterials.Layer.WOOD, Color(0.46, 0.34, 0.22))
	var thatch: ShaderMaterial = SurfaceMaterials.layer_material(
		SurfaceMaterials.Layer.THATCH, THATCH_TINT)
	for post: int in range(4):
		var x: float = -0.85 if post % 2 == 0 else 0.85
		var z: float = -0.55 if post < 2 else 0.55
		_add_block(stall, "Post%d" % post, Vector3(x, 1.0, z), Vector3(0.12, 2.0, 0.12), wood, false)
	# Techo a dos aguas y respaldo de ichu: sin ellos el puesto parece una mesa.
	var roof_front: Node3D = _add_block(
		stall, "RoofFront", Vector3(0.0, 2.02, 0.46), Vector3(2.6, 0.20, 1.10), thatch, false)
	roof_front.rotation_degrees.x = 12.0
	var roof_back: Node3D = _add_block(
		stall, "RoofBack", Vector3(0.0, 2.02, -0.46), Vector3(2.6, 0.20, 1.10), thatch, false)
	roof_back.rotation_degrees.x = -12.0
	# Cumbrera: sin ella los dos faldones se leen como una tabla doblada.
	_add_block(stall, "Ridge", Vector3(0.0, 2.13, 0.0), Vector3(2.66, 0.12, 0.26), thatch, false)
	_add_block(stall, "BackPanel", Vector3(0.0, 1.15, -0.55), Vector3(2.2, 1.5, 0.08), thatch, false)
	_add_block(stall, "Counter", Vector3(0.0, 0.68, 0.15), Vector3(1.9, 0.14, 0.9), wood, true)
	_add_model_prop(stall, "Jar0", MODEL_PROP_JAR, Vector3(-0.5, 0.75, 0.15), 0.4, 0.85)
	_add_model_prop(stall, "Jar1", MODEL_PROP_JAR, Vector3(0.45, 0.75, 0.1), -0.3, 0.75)
	return stall


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
	# Queñuas y matas fuera del muro: el valle deja de ser una llanura vacía.
	var groves: Array[Array] = [
		["pch_quenua_a.glb", Vector3(-40.0, 0.0, 25.0), 1.15],
		["pch_quenua_b.glb", Vector3(-46.0, 0.0, -18.0), 1.0],
		["pch_quenua_a.glb", Vector3(41.0, 0.0, -22.0), 1.2],
		["pch_quenua_b.glb", Vector3(48.0, 0.0, 20.0), 1.05],
		["pch_quenua_a.glb", Vector3(-55.0, 0.0, 4.0), 1.0],
		["pch_quenua_b.glb", Vector3(56.0, 0.0, -2.0), 1.1],
		["pch_ichu_a.glb", Vector3(-34.0, 0.0, 12.0), 1.1],
		["pch_ichu_b.glb", Vector3(34.0, 0.0, 14.0), 1.2],
		["pch_ichu_a.glb", Vector3(-35.0, 0.0, -12.0), 1.0],
		["pch_ichu_b.glb", Vector3(36.0, 0.0, -10.0), 1.1],
	]
	for index: int in range(clumps.size()):
		var entry: Array = clumps[index]
		var file: String = entry[0]
		var at: Vector3 = entry[1]
		var model_scale: float = entry[2]
		_add_model_prop(vegetation, "Ichu%d" % index, file, at, 0.7 * float(index), model_scale)
	for index: int in range(groves.size()):
		var entry: Array = groves[index]
		var file: String = entry[0]
		var at: Vector3 = entry[1]
		at.y = _height_at(at.x, at.z)
		var model_scale: float = entry[2]
		_add_model_prop(vegetation, "Grove%d" % index, file, at, 1.3 * float(index), model_scale)


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
## Cúpula de nubes procedurales, como en la llacta y el paso: el cielo físico
## sigue siendo el fondo y la cúpula solo añade las nubes altas.
func _build_clouds() -> void:
	if not ResourceLoader.exists(CLOUD_SHADER_PATH):
		return
	var shader: Shader = load(CLOUD_SHADER_PATH) as Shader
	if shader == null:
		return
	var material: ShaderMaterial = ShaderMaterial.new()
	material.shader = shader
	# Sobre la plaza las nubes se ven de cerca: más pequeñas y más tenues que
	# en el paisaje abierto, o parecen manchas.
	material.set_shader_parameter("coverage", 0.42)
	material.set_shader_parameter("cloud_scale", 4.6)
	material.set_shader_parameter("opacity", 0.55)
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


## Polvo en suspensión sobre la plaza, como en la llacta: da aire de lugar
## habitado y seco, y ayuda a leer la profundidad del descampado.
func _build_dust() -> void:
	var particles: GPUParticles3D = GPUParticles3D.new()
	particles.name = "Dust"
	particles.amount = 140
	particles.lifetime = 10.0
	particles.preprocess = 5.0
	particles.local_coords = false
	particles.visibility_aabb = AABB(Vector3(-34.0, -2.0, -34.0), Vector3(68.0, 18.0, 68.0))
	var process: ParticleProcessMaterial = ParticleProcessMaterial.new()
	process.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_BOX
	process.emission_box_extents = Vector3(20.0, 3.0, 20.0)
	process.direction = Vector3(0.25, 0.05, -0.1)
	process.spread = 40.0
	process.initial_velocity_min = 0.03
	process.initial_velocity_max = 0.14
	process.gravity = Vector3(0.0, -0.01, 0.0)
	process.scale_min = 0.5
	process.scale_max = 1.2
	process.color = Color(1.0, 0.94, 0.82, 1.0)
	var gradient: Gradient = Gradient.new()
	gradient.set_color(0, Color(1.0, 1.0, 1.0, 1.0))
	gradient.set_color(1, Color(1.0, 1.0, 1.0, 0.0))
	var texture: GradientTexture2D = GradientTexture2D.new()
	texture.gradient = gradient
	texture.fill = GradientTexture2D.FILL_RADIAL
	texture.fill_from = Vector2(0.5, 0.5)
	texture.fill_to = Vector2(1.0, 0.5)
	texture.width = 32
	texture.height = 32
	var mesh: QuadMesh = QuadMesh.new()
	mesh.size = Vector2(0.06, 0.06)
	var material: StandardMaterial3D = StandardMaterial3D.new()
	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	material.billboard_mode = BaseMaterial3D.BILLBOARD_ENABLED
	material.albedo_texture = texture
	material.albedo_color = Color(1.0, 0.96, 0.88, 0.16)
	material.disable_receive_shadows = true
	mesh.material = material
	particles.draw_pass_1 = mesh
	particles.process_material = process
	particles.position = Vector3(0.0, 4.0, 0.0)
	particles.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	add_child(particles)


func _build_crowd() -> void:
	var crowd: Node3D = Node3D.new()
	crowd.name = "Crowd"
	add_child(crowd)
	for index: int in range(CROWD_POSITIONS.size()):
		_add_crowd_figure(crowd, index, CROWD_POSITIONS[index], CROWD_ROLES[index], CROWD_VARIANTS[index])


func _add_crowd_figure(parent: Node3D, index: int, at: Vector3, role: StringName, variant: int) -> void:
	# La multitud usa los mismos modelos que el elenco: seis GLB distintos
	# repartidos en diez puestos, con variación de talla para romper la
	# repetición. Ya no queda ninguna figura procedural en escena.
	var spawn_at: Vector3 = at
	if CROWD_VENDORS.has(index):
		spawn_at = CROWD_VENDORS[index]
	var visual: CharacterModelVisual = CharacterModelVisual.new()
	visual.name = "Crowd%02d" % index
	visual.model_path = MODEL_DIR + CharacterCatalog.model_for(String(role), _character_model_for(role, variant))
	visual.position = spawn_at
	visual.scale = Vector3.ONE * (0.96 + 0.02 * float(index % 5))
	parent.add_child(visual)
	var body: StaticBody3D = StaticBody3D.new()
	body.name = "CrowdBody"
	body.collision_layer = CROWD_COLLISION_LAYER
	body.collision_mask = 0
	var shape: CollisionShape3D = CollisionShape3D.new()
	var capsule: CapsuleShape3D = CapsuleShape3D.new()
	capsule.radius = 0.34
	capsule.height = 1.7
	shape.shape = capsule
	shape.position = Vector3(0.0, 0.85, 0.0)
	body.add_child(shape)
	visual.add_child(body)
	var target: Vector3 = Vector3(0.0, spawn_at.y, 0.0)
	if spawn_at.distance_to(target) > 0.1:
		visual.look_at(target, Vector3.UP)
	visual.play(&"Idle", 0.85 + 0.1 * float(index % 3))
	var member: CrowdMember = CrowdMember.new(visual, CROWD_SAFE_POSITIONS[index], visual.rotation.y)
	member.home = spawn_at
	member.route = crowd_route(index, spawn_at)
	member.route_index = 1 if member.route.size() > 1 else 0
	member.pause_left = 0.8 + 0.55 * float(index)
	member.activity = CROWD_ACTIVITIES[index % CROWD_ACTIVITIES.size()]
	member.activity_left = 4.0 + 0.7 * float(index)
	member.pair = _crowd_pair_for(index)
	member.rng.seed = 7013 + index * 97
	_crowd.append(member)


## Ruta corta alrededor de casa: no cruza el centro de la plaza ni los puestos.
## Las parejas y los vendedores no tienen ruta; se quedan conversando o
## atendiendo.
static func crowd_route(index: int, home: Vector3) -> PackedVector3Array:
	if CROWD_VENDORS.has(index):
		return PackedVector3Array()
	for pair: Vector2i in CROWD_PAIRS:
		if pair.x == index or pair.y == index:
			return PackedVector3Array()
	var points: PackedVector3Array = PackedVector3Array()
	var to_center: Vector3 = Vector3(0.0, home.y, 0.0) - home
	to_center.y = 0.0
	if to_center.length() < 0.5:
		return points
	to_center = to_center.normalized()
	var side: Vector3 = Vector3(-to_center.z, 0.0, to_center.x)
	points.append(home)
	points.append(home + to_center * 1.8 + side * 1.1)
	points.append(home + to_center * 1.0 - side * 1.6)
	points.append(home + side * 0.7)
	return points


static func _crowd_pair_for(index: int) -> int:
	for pair: Vector2i in CROWD_PAIRS:
		if pair.x == index:
			return pair.y
		if pair.y == index:
			return pair.x
	return -1


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
