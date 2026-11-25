extends RefCounted
## Comprueba que los aliados no se plantan en la trayectoria del jugador.
##
## El caso que fallaba en la partida: un aliado esperaba de frente a 4 m y el
## jugador tenía que rodearlo para llegar al estandarte.

const FORWARD: Vector3 = Vector3(0.0, 0.0, -1.0)
const PLAYER: Vector3 = Vector3.ZERO


func test_ally_in_front_cedes_sideways() -> bool:
	var velocity: Vector3 = AlliedWarrior.follow_velocity(Vector3(0.0, 0.0, -1.2), PLAYER, FORWARD)
	var ok: bool = velocity.length() > 0.1
	# Se aparta de la línea de mirada, no empuja al jugador de frente.
	ok = ok and absf(velocity.normalized().dot(FORWARD)) < 0.1
	return ok


func test_ally_too_close_behind_backs_away() -> bool:
	var velocity: Vector3 = AlliedWarrior.follow_velocity(Vector3(0.0, 0.0, 1.2), PLAYER, FORWARD)
	return velocity.length() > 0.1 and velocity.z > 0.0


func test_ally_waits_at_its_spot() -> bool:
	var spot: Vector3 = PLAYER - FORWARD * AlliedWarrior.FOLLOW_DISTANCE
	return AlliedWarrior.follow_velocity(spot, PLAYER, FORWARD).is_zero_approx()


func test_ally_returns_behind_from_the_front() -> bool:
	var velocity: Vector3 = AlliedWarrior.follow_velocity(Vector3(0.0, 0.0, -8.0), PLAYER, FORWARD)
	# El punto de espera está detrás: se mueve hacia +Z, no se queda quieto.
	return velocity.length() > 0.1 and velocity.z > 0.0
