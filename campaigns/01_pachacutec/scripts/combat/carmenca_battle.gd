class_name CarmencaBattle
extends Node
## La batalla de Carmenca: tres oleadas, vecinos aliados y el estandarte.
##
## No simula un ejército: como mucho 8 chancas por oleada y 6 vecinos. Las
## obras de defensa (3.8) quitan un enemigo por oleada cada una, hasta dos; la
## manta de la defensa (3.6) reduce el daño recibido. Perder reinicia la oleada,
## no la partida. Ganar fija `m01_victoria` y cierra la misión.
##
## La batalla no se serializa: si se guarda durante el combate, al cargar se
## vuelve a la etapa 3 antes de empezar.

enum State {
	IDLE,
	WAVE,
	BETWEEN,
	STANDARD,
	FINISHED,
}

const CAMP: Vector3 = Vector3(765.0, 0.0, 295.0)
const WAVES: Array[int] = [4, 6, 8]
const MAX_WORKS_BONUS: int = 2
const ALLY_COUNT: int = 6
const TRIGGER_RADIUS: float = 120.0
const WAVE_DELAY: float = 4.0
const STANDARD_RADIUS: float = 3.5
const STANDARD_HEIGHT: float = 4.2
const MANTA_SCALE: float = 0.85
const SPAWN_RADIUS: float = 13.0
const DEFEAT_DELAY: float = 2.5
const STAGE_FLAG: StringName = &"m01_etapa"
const VICTORY_FLAG: StringName = &"m01_victoria"
const MANTA_FLAG: StringName = &"s01_manta"

var _world: RegionWorld = null
var _works: DefenseWorks = null
var _director: EncounterDirector = null
var _standard: Node3D = null
var _enemies: Array[ChancaWarrior] = []
var _allies: Array[AlliedWarrior] = []
var _state: State = State.IDLE
var _wave: int = 0
var _next_wave: int = 0
var _delay: float = 0.0
var _last_alive: int = -1


func setup(world: RegionWorld, works: DefenseWorks) -> void:
	_world = world
	_works = works
	_director = EncounterDirector.new()
	_director.name = "Director"
	_director.max_attackers = 2
	_director.separation_distance = 1.5
	add_child(_director)
	_build_standard()
	var combat: PlayerCombat = _combat()
	if combat != null:
		combat.died.connect(_on_player_died)


func is_active() -> bool:
	return _state == State.WAVE or _state == State.BETWEEN or _state == State.STANDARD


func is_finished() -> bool:
	return _state == State.FINISHED


func get_state() -> int:
	return int(_state)


func get_wave() -> int:
	return _wave


func get_enemy_count() -> int:
	return _alive_enemies()


func get_ally_count() -> int:
	return _allies.size()


func get_standard_position() -> Vector3:
	return _standard.global_position if _standard != null else CAMP


## Arranca sin esperar a que el jugador llegue. Para pruebas y capturas.
func force_start() -> void:
	if _state != State.IDLE:
		return
	_start()


func _process(delta: float) -> void:
	match _state:
		State.IDLE:
			_check_trigger()
		State.WAVE:
			_refresh_status()
			if _alive_enemies() == 0:
				_on_wave_cleared()
		State.BETWEEN:
			_delay -= delta
			if _delay <= 0.0:
				_start_wave(_next_wave)
		State.STANDARD:
			_check_standard()


func _check_trigger() -> void:
	if _world == null:
		return
	var state: WorldStateService = WorldStateService.instance()
	var player: PlayerFPS = _world.get_player()
	if state == null or player == null:
		return
	if state.get_flag(STAGE_FLAG) < 3:
		return
	var flat: Vector2 = Vector2(
		player.global_position.x - CAMP.x, player.global_position.z - CAMP.z
	)
	if flat.length() <= TRIGGER_RADIUS:
		_start()


func _start() -> void:
	var combat: PlayerCombat = _combat()
	if combat == null:
		return
	combat.set_armed(true)
	combat.set_damage_scale(MANTA_SCALE if _has_manta() else 1.0)
	_spawn_allies()
	_subtitle(&"PCH_BATALLA_ALIADOS")
	_start_wave(1)


func _start_wave(index: int) -> void:
	_wave = index
	_state = State.WAVE
	_last_alive = -1
	_clear_enemies()
	var count: int = WAVES[index - 1]
	var bonus: int = mini(_works.get_built_count() if _works != null else 0, MAX_WORKS_BONUS)
	count = maxi(1, count - bonus)
	for slot: int in count:
		_spawn_enemy(slot, count)
	_subtitle(&"PCH_BATALLA_OLEADA", index)
	_refresh_status()


func _spawn_enemy(slot: int, count: int) -> void:
	var angle: float = TAU * float(slot) / float(maxi(count, 1))
	var radius: float = SPAWN_RADIUS * (0.6 + 0.4 * float((slot * 7) % 5) / 4.0)
	var point: Vector3 = CAMP + Vector3(cos(angle) * radius, 0.0, sin(angle) * radius)
	point.y = _ground(point.x, point.z) + 0.05
	var warrior: ChancaWarrior = ChancaWarrior.new()
	warrior.name = "Chanca_%d_%d" % [_wave, slot]
	_world.add_child(warrior)
	warrior.setup(_world.get_player(), _combat(), point)
	warrior.set_director(_director)
	_enemies.append(warrior)


func _spawn_allies() -> void:
	var player: PlayerFPS = _world.get_player()
	if player == null:
		return
	for slot: int in ALLY_COUNT:
		var angle: float = TAU * float(slot) / float(ALLY_COUNT)
		var point: Vector3 = player.global_position
		point += Vector3(cos(angle), 0.0, sin(angle)) * 4.5
		point.y = _ground(point.x, point.z) + 0.05
		var ally: AlliedWarrior = AlliedWarrior.new()
		ally.name = "Aliado_%d" % slot
		_world.add_child(ally)
		ally.setup(player, point)
		_allies.append(ally)


func _on_wave_cleared() -> void:
	if _wave < WAVES.size():
		_next_wave = _wave + 1
		_state = State.BETWEEN
		_delay = WAVE_DELAY
		_subtitle(&"PCH_BATALLA_OLEADA", _next_wave)
		return
	_state = State.STANDARD
	_subtitle(&"PCH_BATALLA_ESTANDARTE")
	_refresh_status()


func _check_standard() -> void:
	var player: PlayerFPS = _world.get_player()
	if player == null or _standard == null:
		return
	var flat: Vector2 = Vector2(
		player.global_position.x - _standard.global_position.x,
		player.global_position.z - _standard.global_position.z
	)
	if flat.length() <= STANDARD_RADIUS:
		_victory()


func _victory() -> void:
	_state = State.FINISHED
	var state: WorldStateService = WorldStateService.instance()
	if state != null:
		state.set_flag(VICTORY_FLAG, 1)
	_subtitle(&"PCH_BATALLA_VICTORIA")
	var combat: PlayerCombat = _combat()
	if combat != null:
		combat.set_armed(false)
		combat.set_damage_scale(1.0)
	_clear_enemies()
	_clear_allies()
	var hud: PlayerHud = _hud()
	if hud != null:
		hud.set_status("")


func _on_player_died() -> void:
	if _state != State.WAVE and _state != State.STANDARD:
		return
	_clear_enemies()
	_state = State.BETWEEN
	_next_wave = maxi(_wave, 1)
	_delay = DEFEAT_DELAY
	_last_alive = -1
	_subtitle(&"PCH_BATALLA_DERROTA")
	var combat: PlayerCombat = _combat()
	if combat != null:
		combat.revive()
		combat.set_armed(true)
	_move_player_home()
	var hud: PlayerHud = _hud()
	if hud != null:
		hud.set_status("")


func _move_player_home() -> void:
	var player: PlayerFPS = _world.get_player()
	if player == null:
		return
	var point: Vector3 = RegionWorld.SPAWN_POINT
	point.y = _ground(point.x, point.z) + 0.2
	player.global_position = point
	player.rotation_degrees.y = RegionWorld.SPAWN_YAW_DEGREES


func _refresh_status() -> void:
	var alive: int = _alive_enemies()
	if alive == _last_alive:
		return
	_last_alive = alive
	var hud: PlayerHud = _hud()
	if hud == null:
		return
	if alive <= 0:
		hud.set_status("")
		return
	hud.set_status(tr("PCH_BATALLA_ESTADO") % [alive, _wave])


func _alive_enemies() -> int:
	_prune()
	var count: int = 0
	for enemy: ChancaWarrior in _enemies:
		if is_instance_valid(enemy) and not enemy.is_dead():
			count += 1
	return count


func _prune() -> void:
	for enemy: ChancaWarrior in _enemies.duplicate():
		if not is_instance_valid(enemy):
			_enemies.erase(enemy)


func _clear_enemies() -> void:
	for enemy: ChancaWarrior in _enemies:
		if is_instance_valid(enemy):
			enemy.queue_free()
	_enemies.clear()


func _clear_allies() -> void:
	for ally: AlliedWarrior in _allies:
		if is_instance_valid(ally):
			ally.queue_free()
	_allies.clear()


func _build_standard() -> void:
	_standard = Node3D.new()
	_standard.name = "Estandarte"
	_standard.position = Vector3(CAMP.x, _ground(CAMP.x, CAMP.z), CAMP.z)
	add_child(_standard)
	var pole: MeshInstance3D = MeshInstance3D.new()
	pole.name = "Pole"
	var cylinder: CylinderMesh = CylinderMesh.new()
	cylinder.top_radius = 0.06
	cylinder.bottom_radius = 0.08
	cylinder.height = STANDARD_HEIGHT
	cylinder.radial_segments = 7
	pole.mesh = cylinder
	pole.material_override = BlockoutKit.material(Color(0.32, 0.22, 0.13))
	pole.position = Vector3(0.0, STANDARD_HEIGHT * 0.5, 0.0)
	_standard.add_child(pole)
	var cloth: MeshInstance3D = MeshInstance3D.new()
	cloth.name = "Cloth"
	var flag: BoxMesh = BoxMesh.new()
	flag.size = Vector3(1.3, 0.85, 0.05)
	cloth.mesh = flag
	cloth.material_override = BlockoutKit.material(Color(0.58, 0.18, 0.14))
	cloth.position = Vector3(0.75, STANDARD_HEIGHT - 0.6, 0.0)
	_standard.add_child(cloth)


func _has_manta() -> bool:
	var state: WorldStateService = WorldStateService.instance()
	return state != null and state.has_flag(MANTA_FLAG)


func _combat() -> PlayerCombat:
	return _world.get_player_combat() if _world != null else null


func _hud() -> PlayerHud:
	return _world.get_player_hud() if _world != null else null


func _ground(x: float, z: float) -> float:
	return _world.get_region().height_at(x, z) if _world != null else 0.0


func _subtitle(key: StringName, wave: int = 0) -> void:
	var hud: PlayerHud = _hud()
	if hud == null:
		return
	var text: String = tr(String(key))
	if wave > 0:
		text = text % wave
	hud.show_subtitle(text, 5.0)
