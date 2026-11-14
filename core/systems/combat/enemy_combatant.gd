class_name EnemyCombatant
extends Combatant
## Enemigo con una intención sencilla: acercarse, atacar o huir.
##
## No mueve nada: [method think] devuelve la intención y la campaña mueve al
## NPC. La moral manda: por debajo de [member flee_morale] huye y no se
## persigue.

enum Intent {
	IDLE,
	ALERT,
	APPROACH,
	ATTACK,
	FLEE,
}

## Distancia a la que advierte al jugador.
@export var alert_radius: float = 18.0
## Moral por debajo de la cual huye.
@export var flee_morale: float = 25.0

var intent: Intent = Intent.IDLE


## Decide qué hacer este tick y devuelve la intención.
##
## [param distance] es la distancia al objetivo; [param line_of_sight] indica si
## lo ve. El enemigo no ataca si está fuera del alcance del arma.
func think(_delta: float, distance: float, line_of_sight: bool) -> Intent:
	if is_down():
		intent = Intent.IDLE
		return intent
	if character != null and character.get_morale() <= flee_morale:
		if not is_fleeing():
			flee()
		intent = Intent.FLEE
		return intent
	if not line_of_sight or distance > alert_radius:
		intent = Intent.IDLE
		return intent
	if weapon != null and distance <= weapon.range_max and can_attack():
		intent = Intent.ATTACK
		return intent
	intent = Intent.APPROACH
	return intent


## Ataca si el objetivo está en alcance; devuelve el daño o 0.
func try_attack(distance: float, charge: float = 1.0) -> float:
	if weapon == null or distance > weapon.range_max or distance < weapon.range_min:
		return 0.0
	return attack(charge)
