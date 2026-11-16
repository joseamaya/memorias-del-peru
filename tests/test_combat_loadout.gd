extends RefCounted
## Comprueba el loadout de combate: honda con piedras, porra corta y escudo.


func test_loadout_weapons_and_ammo() -> bool:
	CampaignState.clear()
	var tree: SceneTree = Engine.get_main_loop() as SceneTree
	if tree == null:
		return false
	var character: CharacterState = CharacterState.new()
	var stamina: StaminaComponent = StaminaComponent.new()
	stamina.restore(stamina.get_maximum())
	var combatant: Combatant = Combatant.new()
	combatant.character = character
	combatant.stamina = stamina
	var loadout: CombatLoadout = CombatLoadout.new()
	loadout.character = character
	loadout.stamina = stamina
	loadout.combatant = combatant
	tree.root.add_child(loadout)
	loadout.set_ammo(3)
	var ok: bool = loadout.current_weapon() != null
	ok = ok and loadout.current_weapon().kind == CombatWeapon.Kind.SLING
	ok = ok and loadout.is_ranged()
	ok = ok and loadout.can_attack()
	ok = ok and loadout.attack(1.0) > 0.0
	ok = ok and loadout.ammo() == 2
	ok = ok and loadout.switch_to(CombatLoadout.Slot.CLUB)
	ok = ok and not loadout.is_ranged()
	ok = ok and is_equal_approx(loadout.range_max(), 1.6)
	combatant.advance(1.0)
	ok = ok and loadout.attack(1.0) > 0.0
	ok = ok and loadout.ammo() == 2
	ok = ok and loadout.switch_to(CombatLoadout.Slot.SHIELD)
	ok = ok and loadout.is_shield()
	ok = ok and not loadout.can_attack()
	ok = ok and is_equal_approx(loadout.block_ratio(), 0.7)
	ok = ok and not loadout.switch_to(99)
	loadout.set_ammo(0)
	ok = ok and loadout.switch_to(CombatLoadout.Slot.SLING)
	ok = ok and not loadout.can_attack()
	loadout.free()
	combatant.free()
	stamina.free()
	character.free()
	CampaignState.clear()
	return ok
