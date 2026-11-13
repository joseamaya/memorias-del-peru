extends RefCounted
## Comprueba el estado de personaje: salud, ánimo, habilidades por uso y
## reputación por grupo (ADR-0038).


func test_character_damage_and_death() -> bool:
	var state: CharacterState = CharacterState.new()
	var deaths: Array[bool] = [false]
	state.died.connect(func() -> void: deaths[0] = true)
	state.damage(30.0)
	var ok: bool = is_equal_approx(state.get_health(), 70.0)
	ok = ok and not deaths[0]
	state.damage(100.0)
	ok = ok and is_zero_approx(state.get_health())
	ok = ok and deaths[0] and not state.is_alive()
	state.heal(20.0)
	ok = ok and is_zero_approx(state.get_health())
	state.free()
	return ok


func test_character_heal_and_morale() -> bool:
	var state: CharacterState = CharacterState.new()
	state.damage(40.0)
	state.heal(100.0)
	var ok: bool = is_equal_approx(state.get_health(), state.get_max_health())
	state.change_morale(-150.0)
	ok = ok and is_zero_approx(state.get_morale())
	state.change_morale(30.0)
	ok = ok and is_equal_approx(state.get_morale(), 30.0)
	state.change_morale(500.0)
	ok = ok and is_equal_approx(state.get_morale(), state.get_max_morale())
	state.free()
	return ok


func test_character_skills_by_use() -> bool:
	var state: CharacterState = CharacterState.new()
	var ranks: Array[int] = []
	state.skill_changed.connect(func(_skill: StringName, rank: int) -> void: ranks.append(rank))
	var ok: bool = state.register_skill_use(&"honda", 2) == 0
	ok = ok and state.register_skill_use(&"honda", 1) == 1
	ok = ok and state.register_skill_use(&"honda", 5) == 2
	ok = ok and state.register_skill_use(&"honda", 7) == 3
	ok = ok and state.register_skill_use(&"honda", 9) == 4
	ok = ok and state.register_skill_use(&"honda", 11) == 5
	ok = ok and state.register_skill_use(&"honda", 100) == 5
	ok = ok and state.get_skill_uses(&"honda") == 135
	ok = ok and ranks == [1, 2, 3, 4, 5]
	ok = ok and state.get_skill(&"palabra") == 0
	state.free()
	return ok


func test_character_skill_rank_boundaries() -> bool:
	var ok: bool = CharacterState.rank_for_uses(0) == 0
	ok = ok and CharacterState.rank_for_uses(2) == 0
	ok = ok and CharacterState.rank_for_uses(3) == 1
	ok = ok and CharacterState.rank_for_uses(7) == 1
	ok = ok and CharacterState.rank_for_uses(8) == 2
	ok = ok and CharacterState.rank_for_uses(35) == 5
	ok = ok and CharacterState.rank_for_uses(999) == CharacterState.MAX_SKILL_RANK
	return ok


func test_character_reputation_limits() -> bool:
	var state: CharacterState = CharacterState.new()
	var ok: bool = state.get_reputation(&"llacta") == 0
	ok = ok and state.change_reputation(&"llacta", 1) == 1
	ok = ok and state.change_reputation(&"llacta", 5) == CharacterState.MAX_REPUTATION
	ok = ok and state.change_reputation(&"llacta", -10) == CharacterState.MIN_REPUTATION
	state.set_reputation(&"cusco", 2)
	ok = ok and state.get_reputation(&"cusco") == 2
	state.free()
	return ok


func test_character_reset() -> bool:
	var state: CharacterState = CharacterState.new()
	state.damage(50.0)
	state.change_morale(-50.0)
	state.register_skill_use(&"honda", 10)
	state.change_reputation(&"llacta", 2)
	state.reset()
	var ok: bool = is_equal_approx(state.get_health(), state.get_max_health())
	ok = ok and is_equal_approx(state.get_morale(), state.get_max_morale())
	ok = ok and state.get_skill(&"honda") == 0
	ok = ok and state.get_reputation(&"llacta") == 0
	state.free()
	return ok
