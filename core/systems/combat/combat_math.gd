class_name CombatMath
extends RefCounted
## Reglas numéricas del combate, separadas de la escena y de la entrada.
##
## Son funciones puras para poder probarlas sin pantalla. El daño sube con la
## carga y con el rango de habilidad; no hay números aleatorios en el impacto:
## la dispersión se resuelve en la puntería, no con una tirada oculta.

## Factor de habilidad: 0,55 con rango 0 y 1,0 con rango 5.
const SKILL_FACTOR_BASE: float = 0.55
const SKILL_FACTOR_STEP: float = 0.09


## Proporción de carga (0–1) para un tiempo de pulsación.
static func charge_ratio(elapsed_seconds: float, weapon: CombatWeapon) -> float:
	if weapon == null or weapon.charge_full_seconds <= 0.0:
		return 1.0
	return clampf(elapsed_seconds / weapon.charge_full_seconds, 0.0, 1.0)


## Daño de un golpe con una carga y un rango de habilidad dados.
static func damage(weapon: CombatWeapon, skill_rank: int, charge: float) -> float:
	if weapon == null or weapon.is_shield():
		return 0.0
	var rank: int = clampi(skill_rank, 0, CharacterState.MAX_SKILL_RANK)
	var factor: float = SKILL_FACTOR_BASE + SKILL_FACTOR_STEP * float(rank)
	var base: float = lerpf(weapon.damage_min, weapon.damage_max, clampf(charge, 0.0, 1.0))
	return base * factor


## Daño de un golpe a partir del tiempo de carga.
static func damage_at(weapon: CombatWeapon, skill_rank: int, elapsed_seconds: float) -> float:
	return damage(weapon, skill_rank, charge_ratio(elapsed_seconds, weapon))


## Daño que queda tras un bloqueo con escudo.
static func after_block(amount: float, shield: CombatWeapon) -> float:
	if shield == null or not shield.is_shield():
		return amount
	return amount * (1.0 - shield.block_ratio)
