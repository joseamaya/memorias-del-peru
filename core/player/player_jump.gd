class_name PlayerJump
extends RefCounted
## Estado mínimo del salto del jugador.
##
## La intención se registra en la entrada y se aplica después de la gravedad,
## cuando el cuerpo ya sabe si está en el suelo. Vive aparte de [PlayerFPS] para
## que el controlador no siga creciendo con cada acción.

const DEFAULT_VELOCITY: float = 4.5

var velocity: float = DEFAULT_VELOCITY
var _requested: bool = false


## Registra la intención de saltar. Solo si se pulsó, está en el suelo y libre.
func request(pressed: bool, grounded: bool, locked: bool) -> void:
	if pressed and grounded and not locked:
		_requested = true


## Aplica la intención pendiente. Devuelve si el salto se ejecutó.
func apply(body: CharacterBody3D, grounded: bool, locked: bool) -> bool:
	if not _requested:
		return false
	_requested = false
	if not grounded or locked:
		return false
	body.velocity.y = velocity
	return true
