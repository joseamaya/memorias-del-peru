class_name CombatArenaCheck
extends Node3D
## Arena mínima para probar el combate sin la campaña: un jugador, tres
## chancas y un director de encuentro. El jugador es un bot que dispara con la
## honda cuando puede; el objetivo es medir fichas, resolución y atascos, no
## equilibrar el daño.

const PLAYER_SCENE: String = "res://core/player/player_fps.tscn"
const ENEMY_POSITIONS: Array[Vector3] = [
	Vector3(0.0, 0.0, 2.0),
	Vector3(0.9, 0.0, 2.8),
	Vector3(-0.9, 0.0, 3.2),
]

var player: PlayerFPS = null
var character: CharacterState = null
var combatant: Combatant = null
var loadout: CombatLoadout = null
var director: EncounterDirector = null

var _attack_ray: RayCast3D = null
var _hit_stop: HitStop = null
var _pending_damage: float = 0.0
var _enemies: Array[AmbushEnemy] = []
var _resolved: int = 0
var _max_attackers: int = 0
var _finished: bool = false


func _ready() -> void:
	_build_floor()
	_spawn_player()
	_setup_combat()
	_spawn_enemies()


func _physics_process(_delta: float) -> void:
	if _finished:
		return
	if director != null:
		_max_attackers = maxi(_max_attackers, director.token_count())
	if character == null or not character.is_alive():
		_finished = true
		return
	if _resolved >= _enemies.size():
		_finished = true
		return
	var target: AmbushEnemy = _nearest_enemy()
	if target == null:
		return
	# El bot encara al objetivo antes de disparar: el rayo sale del centro de
	# la cámara y, sin girar, solo acertaría al enemigo alineado.
	var to_target: Vector3 = target.global_position - player.global_position
	to_target.y = 0.0
	if to_target.length() > 0.05:
		player.rotation.y = atan2(-to_target.x, -to_target.z)
	if loadout != null and loadout.can_attack():
		_pending_damage = loadout.attack(1.0)


## La arena siempre está en combate.
func is_ambush_active() -> bool:
	return not _finished


func apply_player_damage(amount: float, _source: Node = null) -> void:
	if character == null:
		return
	var applied: float = loadout.resolve_incoming_damage(amount) if loadout != null else amount
	character.damage(applied)


func on_enemy_resolved() -> void:
	_resolved += 1


func max_attackers() -> int:
	return _max_attackers


func resolved_count() -> int:
	return _resolved


func enemy_count() -> int:
	return _enemies.size()


func is_finished() -> bool:
	return _finished


func player_alive() -> bool:
	return character != null and character.is_alive()


func _build_floor() -> void:
	var body: StaticBody3D = StaticBody3D.new()
	body.name = "Floor"
	var shape: CollisionShape3D = CollisionShape3D.new()
	var box: BoxShape3D = BoxShape3D.new()
	box.size = Vector3(40.0, 0.2, 40.0)
	shape.shape = box
	shape.position = Vector3(0.0, -0.1, 0.0)
	body.add_child(shape)
	var mesh: MeshInstance3D = MeshInstance3D.new()
	var box_mesh: BoxMesh = BoxMesh.new()
	box_mesh.size = Vector3(40.0, 0.2, 40.0)
	mesh.mesh = box_mesh
	mesh.position = Vector3(0.0, -0.1, 0.0)
	var material: StandardMaterial3D = StandardMaterial3D.new()
	material.albedo_color = Color(0.42, 0.38, 0.31, 1.0)
	material.roughness = 1.0
	mesh.material_override = material
	body.add_child(mesh)
	add_child(body)


func _spawn_player() -> void:
	player = (load(PLAYER_SCENE) as PackedScene).instantiate() as PlayerFPS
	player.name = "Player"
	player.position = Vector3(0.0, 0.05, 8.0)
	add_child(player)


func _setup_combat() -> void:
	character = CharacterState.new()
	character.name = "CharacterState"
	character.max_health = 500.0
	character.health = 500.0
	player.add_child(character)
	combatant = Combatant.new()
	combatant.name = "Combatant"
	combatant.character = character
	combatant.stamina = player.stamina
	player.add_child(combatant)
	loadout = CombatLoadout.new()
	loadout.name = "CombatLoadout"
	loadout.character = character
	loadout.stamina = player.stamina
	loadout.combatant = combatant
	player.add_child(loadout)
	loadout.attack_started.connect(_on_attack_started)
	loadout.attack_active.connect(_on_attack_active)
	loadout.set_ammo(999)
	var camera: Camera3D = player.get_node_or_null("Head/Camera3D") as Camera3D
	if camera != null:
		_attack_ray = RayCast3D.new()
		_attack_ray.name = "AttackRay"
		_attack_ray.collision_mask = 9
		_attack_ray.enabled = true
		camera.add_child(_attack_ray)
	_hit_stop = HitStop.new()
	_hit_stop.name = "HitStop"
	add_child(_hit_stop)


func _spawn_enemies() -> void:
	director = EncounterDirector.new()
	director.name = "EncounterDirector"
	director.max_attackers = 2
	director.grant_spacing = 0.5
	add_child(director)
	for index: int in range(ENEMY_POSITIONS.size()):
		var enemy: AmbushEnemy = AmbushEnemy.new()
		enemy.name = "Enemy%d" % (index + 1)
		enemy.position = ENEMY_POSITIONS[index]
		add_child(enemy)
		enemy.setup(player, self)
		enemy.director = director
		director.register(enemy)
		_enemies.append(enemy)


func _nearest_enemy() -> AmbushEnemy:
	var best: AmbushEnemy = null
	var best_distance: float = INF
	for enemy: AmbushEnemy in _enemies:
		if not enemy.is_alive():
			continue
		var distance: float = player.global_position.distance_to(enemy.global_position)
		if distance < best_distance:
			best_distance = distance
			best = enemy
	return best


func _on_attack_started(weapon: CombatWeapon) -> void:
	var visual: FirstPersonWeapon = player.get_node_or_null(
		"Head/Camera3D/FirstPersonWeapon") as FirstPersonWeapon
	if visual != null and weapon != null:
		visual.play_attack(
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
	enemy.take_hit(_pending_damage)
	if _hit_stop != null:
		_hit_stop.trigger(0.03)
