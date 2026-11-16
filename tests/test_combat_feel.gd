extends RefCounted
## Comprueba el compás del golpe, el parry y el director de encuentro.


func _make_loadout() -> CombatLoadout:
	var tree: SceneTree = Engine.get_main_loop() as SceneTree
	var character: CharacterState = CharacterState.new()
	var stamina: StaminaComponent = StaminaComponent.new()
	stamina.restore(stamina.get_maximum())
	var combatant: Combatant = Combatant.new()
	combatant.set_process(false)
	var loadout: CombatLoadout = CombatLoadout.new()
	loadout.add_child(character)
	loadout.add_child(stamina)
	loadout.add_child(combatant)
	loadout.character = character
	loadout.stamina = stamina
	loadout.combatant = combatant
	combatant.character = character
	combatant.stamina = stamina
	tree.root.add_child(loadout)
	loadout.set_process(false)
	return loadout


func test_attack_has_windup_active_recovery() -> bool:
	var loadout: CombatLoadout = _make_loadout()
	loadout.switch_to(CombatLoadout.Slot.CLUB)
	var active: Array[int] = [0]
	loadout.attack_active.connect(func(_weapon: CombatWeapon) -> void: active[0] += 1)
	var damage: float = loadout.attack(1.0)
	var ok: bool = damage > 0.0
	ok = ok and loadout.is_attacking()
	ok = ok and loadout.current_phase() == CombatLoadout.AttackPhase.WINDUP
	ok = ok and not loadout.can_attack()
	loadout.advance(0.23)
	ok = ok and loadout.current_phase() == CombatLoadout.AttackPhase.ACTIVE
	ok = ok and active[0] == 1
	loadout.advance(0.14)
	ok = ok and loadout.current_phase() == CombatLoadout.AttackPhase.RECOVERY
	loadout.advance(0.35)
	ok = ok and not loadout.is_attacking()
	ok = ok and loadout.current_phase() == CombatLoadout.AttackPhase.DONE
	ok = ok and active[0] == 1
	loadout.combatant.advance(2.0)
	ok = ok and loadout.can_attack()
	loadout.free()
	return ok


func test_frame_spike_still_lands_the_hit() -> bool:
	var loadout: CombatLoadout = _make_loadout()
	loadout.switch_to(CombatLoadout.Slot.CLUB)
	var active: Array[int] = [0]
	loadout.attack_active.connect(func(_weapon: CombatWeapon) -> void: active[0] += 1)
	var damage: float = loadout.attack(1.0)
	var ok: bool = damage > 0.0
	# Un tirón de frame salta la ventana activa: el golpe ocurrió y debe emitirse.
	loadout.advance(2.0)
	ok = ok and active[0] == 1
	ok = ok and not loadout.is_attacking()
	loadout.free()
	return ok


func test_parry_and_block_resolve_damage() -> bool:
	var loadout: CombatLoadout = _make_loadout()
	loadout.switch_to(CombatLoadout.Slot.SHIELD)
	var parried: Array[int] = [0]
	var blocked: Array[int] = [0]
	loadout.parried.connect(func() -> void: parried[0] += 1)
	loadout.blocked.connect(func() -> void: blocked[0] += 1)
	loadout.set_blocking(true)
	var perfect: float = loadout.resolve_incoming_damage(30.0)
	var ok: bool = is_zero_approx(perfect)
	ok = ok and parried[0] == 1
	ok = ok and blocked[0] == 0
	loadout.advance(0.2)
	var normal: float = loadout.resolve_incoming_damage(30.0)
	ok = ok and is_equal_approx(normal, 9.0)
	ok = ok and blocked[0] == 1
	ok = ok and is_equal_approx(
		loadout.stamina.get_current(), loadout.stamina.get_maximum() - 5.0)
	loadout.set_blocking(false)
	ok = ok and is_equal_approx(loadout.resolve_incoming_damage(30.0), 30.0)
	loadout.free()
	return ok


func test_encounter_director_limits_attackers() -> bool:
	var tree: SceneTree = Engine.get_main_loop() as SceneTree
	var director: EncounterDirector = EncounterDirector.new()
	director.max_attackers = 2
	director.grant_spacing = 0.0
	tree.root.add_child(director)
	director.set_physics_process(false)
	var members: Array[Node3D] = []
	for index: int in range(3):
		var member: Node3D = Node3D.new()
		member.name = "Member%d" % index
		tree.root.add_child(member)
		members.append(member)
		director.register(member)
	var ok: bool = director.request_token(members[0])
	ok = ok and director.request_token(members[1])
	ok = ok and not director.request_token(members[2])
	ok = ok and director.token_count() == 2
	director.release_token(members[0])
	ok = ok and director.request_token(members[2])
	ok = ok and director.token_count() == 2
	ok = ok and director.has_token(members[2])
	members[0].position = Vector3.ZERO
	members[1].position = Vector3(0.5, 0.0, 0.0)
	var push: Vector3 = director.separation(members[0])
	ok = ok and push.length() > 0.0
	director.unregister(members[1])
	ok = ok and not director.has_token(members[1])
	for member: Node3D in members:
		member.free()
	director.free()
	return ok


func test_camera_kick_returns_to_base() -> bool:
	var tree: SceneTree = Engine.get_main_loop() as SceneTree
	var camera: Camera3D = Camera3D.new()
	tree.root.add_child(camera)
	var kick: CameraKick = CameraKick.new()
	kick.camera = camera
	tree.root.add_child(kick)
	kick.set_process(false)
	kick.kick(-2.0, 1.0)
	var ok: bool = not is_zero_approx(camera.rotation.x)
	ok = ok and not is_zero_approx(camera.rotation.y)
	kick.advance(0.08)
	ok = ok and absf(camera.rotation.x) > 0.0
	kick.advance(0.10)
	ok = ok and is_zero_approx(camera.rotation.x)
	ok = ok and is_zero_approx(camera.rotation.y)
	kick.free()
	camera.free()
	return ok
