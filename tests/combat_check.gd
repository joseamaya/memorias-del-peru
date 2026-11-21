extends SceneTree
## Comprueba el combate del jugador (F3.9.a): arma, golpe, daño y bloqueo.
##
## Arma al jugador, pone un chanca delante, comprueba que el golpe le quita
## salud, que el chanca devuelve el golpe, que el escudo reduce el daño y que la
## honda gasta piedra. No prueba oleadas ni batalla: eso es 3.9.b.

const SCENE_PATH: String = "res://campaigns/01_pachacutec/scenes/world/region_world.tscn"
const SETTLE_FRAMES: int = 600
const CLUB_DISTANCE: float = 1.0
const ATTACK_SETTLE: float = 0.9
const ENEMY_SETTLE: float = 2.6
const START_HEALTH: float = 120.0


func _initialize() -> void:
	_run.call_deferred()


func _run() -> void:
	var world: RegionWorld = (load(SCENE_PATH) as PackedScene).instantiate() as RegionWorld
	root.add_child(world)
	var ready: bool = await _wait_ready(world)
	var ok: bool = ready
	var player: PlayerFPS = world.get_player()
	var combat: PlayerCombat = world.get_player_combat()
	var hud: PlayerHud = world.get_player_hud()
	var region: CampaignRegion = world.get_region()
	ok = ok and player != null and combat != null and hud != null and region != null
	if not ok:
		printerr("COMBAT_FAIL sin jugador, combate o HUD")
		world.queue_free()
		await process_frame
		quit(1)
		return

	# Desarmado no hay arma ni se puede atacar.
	ok = ok and not combat.is_armed()
	var weapon_view: FirstPersonWeapon = (
		player.get_node("Head/Camera3D/FirstPersonWeapon") as FirstPersonWeapon
	)
	ok = ok and weapon_view != null and not weapon_view.visible
	ok = ok and is_zero_approx(combat.try_attack(1.0))
	combat.set_armed(true)
	await process_frame
	ok = ok and combat.is_armed() and weapon_view.visible
	ok = ok and hud.is_ammo_visible()

	# Un chanca delante, al alcance de la porra.
	var warrior: ChancaWarrior = ChancaWarrior.new()
	warrior.name = "TestChanca"
	world.add_child(warrior)
	var forward: Vector3 = -player.camera.global_transform.basis.z
	var at: Vector3 = player.global_position + forward * CLUB_DISTANCE
	# El jugador está sobre la plaza elevada; el chanca se coloca a su altura.
	at.y = player.global_position.y + 0.1
	warrior.setup(player, combat, at)
	await process_frame
	await process_frame
	ok = ok and not warrior.is_dead()

	# Golpe con la porra: el rayo llega y el chanca pierde salud.
	ok = ok and combat.select_weapon(1)
	await process_frame
	ok = ok and combat.loadout.current_weapon().kind == CombatWeapon.Kind.CLUB
	var enemy_before: float = warrior.get_health()
	var club_hit: float = combat.try_attack(1.0)
	await _wait_seconds(ATTACK_SETTLE)
	ok = ok and club_hit > 0.0
	ok = ok and warrior.get_health() < enemy_before

	# El chanca devuelve el golpe: el jugador pierde salud.
	await _wait_seconds(ENEMY_SETTLE)
	ok = ok and combat.get_health() < START_HEALTH

	# Escudo: un golpe de 20 quita bastante menos.
	var shield_ok: bool = combat.select_weapon(2)
	ok = ok and shield_ok
	combat.loadout.set_blocking(true)
	# Fuera de la ventana de parry: aquí el escudo absorbe, no anula.
	await _wait_seconds(0.3)
	await process_frame
	var health_shield: float = combat.get_health()
	combat.take_damage(20.0)
	await process_frame
	var lost: float = health_shield - combat.get_health()
	ok = ok and lost > 0.0 and lost < 20.0
	combat.loadout.set_blocking(false)

	# Honda: cambia el arma, gasta piedra y deja el aviso en el HUD.
	var sling_ok: bool = combat.select_weapon(0)
	ok = ok and sling_ok
	await process_frame
	var ammo_before: int = combat.loadout.ammo()
	ok = ok and ammo_before > 0
	var sling_hit: float = combat.try_attack(1.0)
	await process_frame
	ok = ok and sling_hit > 0.0
	ok = ok and combat.loadout.ammo() == ammo_before - 1
	ok = ok and hud.is_ammo_visible()

	# Derribo: el chanca cae y deja de responder.
	warrior.take_damage(500.0)
	await process_frame
	ok = ok and warrior.is_dead()

	print(
		"COMBAT vida=",
		snappedf(combat.get_health(), 0.1),
		" chanca=",
		snappedf(warrior.get_health(), 0.1),
		" honda=",
		combat.loadout.ammo(),
		" armado=",
		combat.is_armed()
	)
	world.queue_free()
	await process_frame
	if ok:
		print("COMBAT_OK")
	else:
		printerr("COMBAT_FAIL")
	quit(0 if ok else 1)


func _wait_ready(world: RegionWorld) -> bool:
	for _i: int in SETTLE_FRAMES:
		await process_frame
		if world.get_player() != null and world.get_player_combat() != null:
			return true
	return false


func _wait_seconds(seconds: float) -> void:
	await create_timer(seconds).timeout
