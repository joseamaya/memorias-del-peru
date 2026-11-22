extends RefCounted
## Comprueba las reglas de combate: carga, daño, aliento, aturdimiento y moral
## enemiga (ADR-0038).


func _weapon(kind: CombatWeapon.Kind = CombatWeapon.Kind.SLING) -> CombatWeapon:
	var weapon: CombatWeapon = CombatWeapon.new()
	weapon.kind = kind
	weapon.damage_min = 18.0
	weapon.damage_max = 32.0
	weapon.range_min = 3.0
	weapon.range_max = 28.0
	weapon.charge_full_seconds = 1.2
	weapon.stamina_cost = 10.0
	weapon.cooldown_seconds = 0.8
	return weapon


func _stamina() -> StaminaComponent:
	var stamina: StaminaComponent = StaminaComponent.new()
	stamina.restore(stamina.get_maximum())
	return stamina


func test_combat_math_charge_and_damage() -> bool:
	var weapon: CombatWeapon = _weapon()
	var ok: bool = is_zero_approx(CombatMath.charge_ratio(0.0, weapon))
	ok = ok and is_equal_approx(CombatMath.charge_ratio(0.6, weapon), 0.5)
	ok = ok and is_equal_approx(CombatMath.charge_ratio(3.0, weapon), 1.0)
	ok = ok and is_equal_approx(CombatMath.damage(weapon, 0, 0.0), 9.9)
	ok = ok and is_equal_approx(CombatMath.damage(weapon, 5, 1.0), 32.0)
	ok = ok and is_equal_approx(CombatMath.damage(weapon, 2, 0.5), 18.25)
	ok = ok and is_equal_approx(CombatMath.damage_at(weapon, 5, 1.2), 32.0)
	return ok


func test_combat_math_block() -> bool:
	var shield: CombatWeapon = _weapon(CombatWeapon.Kind.SHIELD)
	var ok: bool = is_equal_approx(CombatMath.after_block(30.0, shield), 9.0)
	ok = ok and is_equal_approx(CombatMath.after_block(30.0, null), 30.0)
	ok = ok and is_zero_approx(CombatMath.damage(shield, 5, 1.0))
	return ok


func test_combatant_attack_and_cooldown() -> bool:
	var character: CharacterState = CharacterState.new()
	var stamina: StaminaComponent = _stamina()
	var weapon: CombatWeapon = _weapon()
	var combatant: Combatant = Combatant.new()
	combatant.character = character
	combatant.weapon = weapon
	combatant.stamina = stamina
	var ok: bool = combatant.can_attack()
	var damage: float = combatant.attack(1.0)
	ok = ok and is_equal_approx(damage, 17.6)
	ok = ok and is_equal_approx(stamina.get_current(), 90.0)
	ok = ok and not combatant.can_attack()
	combatant.advance(0.8)
	ok = ok and combatant.can_attack()
	ok = ok and character.get_skill(&"honda") == 0
	combatant.register_hit()
	ok = ok and character.get_skill(&"honda") == 0
	combatant.register_hit()
	combatant.register_hit()
	ok = ok and character.get_skill(&"honda") == 1
	character.free()
	stamina.free()
	combatant.free()
	return ok


func test_stagger_does_not_skip_cooldown() -> bool:
	var character: CharacterState = CharacterState.new()
	var stamina: StaminaComponent = _stamina()
	var combatant: Combatant = Combatant.new()
	combatant.character = character
	combatant.weapon = _weapon()
	combatant.stamina = stamina
	var ok: bool = combatant.attack(1.0) > 0.0
	# El golpe deja la espera en 0,8 s; el aturdimiento dura 0,35 s.
	combatant.take_damage(5.0)
	combatant.advance(0.35)
	ok = ok and not combatant.can_attack()
	combatant.advance(0.45)
	ok = ok and combatant.can_attack()
	character.free()
	stamina.free()
	combatant.free()
	return ok


func test_combatant_without_stamina_cannot_attack() -> bool:
	var character: CharacterState = CharacterState.new()
	var stamina: StaminaComponent = _stamina()
	stamina.consume(95.0)
	var combatant: Combatant = Combatant.new()
	combatant.character = character
	combatant.weapon = _weapon()
	combatant.stamina = stamina
	var ok: bool = not combatant.can_attack()
	ok = ok and is_zero_approx(combatant.attack(1.0))
	character.free()
	stamina.free()
	combatant.free()
	return ok


func test_combatant_take_damage_and_down() -> bool:
	var character: CharacterState = CharacterState.new()
	var combatant: Combatant = Combatant.new()
	combatant.character = character
	var defeated: Array[bool] = [false]
	combatant.defeated.connect(func() -> void: defeated[0] = true)
	combatant.take_damage(30.0, 10.0)
	var ok: bool = is_equal_approx(character.get_health(), 70.0)
	ok = ok and is_equal_approx(character.get_morale(), 90.0)
	ok = ok and combatant.state == Combatant.State.STAGGERED
	combatant.advance(0.35)
	ok = ok and combatant.state == Combatant.State.READY
	combatant.take_damage(100.0)
	ok = ok and combatant.is_down() and defeated[0]
	ok = ok and not character.is_alive()
	character.free()
	combatant.free()
	return ok


func test_enemy_attacks_in_range() -> bool:
	var character: CharacterState = CharacterState.new()
	var enemy: EnemyCombatant = EnemyCombatant.new()
	enemy.character = character
	enemy.weapon = _weapon()
	var ok: bool = enemy.think(0.0, 10.0, true) == EnemyCombatant.Intent.ATTACK
	ok = ok and enemy.try_attack(10.0, 1.0) > 0.0
	ok = ok and is_zero_approx(enemy.try_attack(40.0, 1.0))
	character.free()
	enemy.free()
	return ok


func test_enemy_approaches_out_of_range() -> bool:
	var character: CharacterState = CharacterState.new()
	var enemy: EnemyCombatant = EnemyCombatant.new()
	enemy.character = character
	enemy.weapon = _weapon()
	enemy.alert_radius = 50.0
	var ok: bool = enemy.think(0.0, 40.0, true) == EnemyCombatant.Intent.APPROACH
	ok = ok and enemy.think(0.0, 40.0, false) == EnemyCombatant.Intent.IDLE
	ok = ok and enemy.think(0.0, 60.0, true) == EnemyCombatant.Intent.IDLE
	character.free()
	enemy.free()
	return ok


func test_enemy_flees_at_low_morale() -> bool:
	var character: CharacterState = CharacterState.new()
	var enemy: EnemyCombatant = EnemyCombatant.new()
	enemy.character = character
	enemy.weapon = _weapon()
	var ok: bool = enemy.think(0.0, 10.0, true) == EnemyCombatant.Intent.ATTACK
	enemy.take_damage(10.0, 80.0)
	ok = ok and enemy.think(0.0, 10.0, true) == EnemyCombatant.Intent.FLEE
	ok = ok and enemy.is_fleeing()
	character.free()
	enemy.free()
	return ok
