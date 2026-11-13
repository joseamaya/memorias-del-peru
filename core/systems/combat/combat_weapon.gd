class_name CombatWeapon
extends Resource
## Arma del RPG: honda, porra o escudo. Solo datos y reglas simples; el
## proyectil y la animación viven en la campaña.

enum Kind {
	SLING,
	CLUB,
	SHIELD,
}

## Tipo de arma.
@export var kind: Kind = Kind.SLING
## Daño mínimo con carga nula y habilidad cero.
@export var damage_min: float = 18.0
## Daño máximo con carga completa y habilidad máxima.
@export var damage_max: float = 32.0
## Alcance mínimo útil, en metros.
@export var range_min: float = 3.0
## Alcance máximo, en metros.
@export var range_max: float = 28.0
## Tiempo de carga completa, en segundos.
@export var charge_full_seconds: float = 1.2
## Aliento que cuesta cada ataque.
@export var stamina_cost: float = 10.0
## Espera entre ataques, en segundos.
@export var cooldown_seconds: float = 0.8
## Proporción del daño que bloquea un escudo (0–1).
@export_range(0.0, 1.0, 0.05) var block_ratio: float = 0.7


## Indica si el arma ataca a distancia.
func is_ranged() -> bool:
	return kind == Kind.SLING


## Indica si el arma es un escudo.
func is_shield() -> bool:
	return kind == Kind.SHIELD
