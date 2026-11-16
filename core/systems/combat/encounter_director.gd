class_name EncounterDirector
extends Node
## Reparte fichas de ataque y separa a los enemigos de un encuentro.
##
## Sin director, cada enemigo ataca por su cuenta y cuatro chancas se apilan
## sobre el jugador. Con él, como máximo [member max_attackers] atacan a la vez;
## el resto rodea, espera o amaga. Es la diferencia entre una pelea legible y
## una nube de golpes.

@export_range(1, 6, 1) var max_attackers: int = 2
## Tiempo mínimo entre dos concesiones, para que no ataquen todos a la vez.
@export_range(0.0, 5.0, 0.05, "suffix:s") var grant_spacing: float = 0.55
## Distancia a la que los enemigos se empujan para no solaparse.
@export_range(0.0, 5.0, 0.05, "suffix:m") var separation_distance: float = 1.4
@export_range(0.0, 5.0, 0.05) var separation_strength: float = 0.8

var _members: Array[Node3D] = []
var _holders: Array[Node3D] = []
var _since_grant: float = INF


func _physics_process(delta: float) -> void:
	tick(delta)


## Avanza el espaciado. Público para las pruebas.
func tick(delta: float) -> void:
	_since_grant += delta
	_prune()


## Registra un enemigo del encuentro.
func register(enemy: Node3D) -> void:
	if enemy == null or _members.has(enemy):
		return
	_members.append(enemy)
	if not enemy.tree_exiting.is_connected(_on_member_exiting):
		enemy.tree_exiting.connect(_on_member_exiting.bind(enemy))


## Pide permiso para atacar. Si ya tiene ficha, la conserva.
func request_token(enemy: Node3D) -> bool:
	_prune()
	if _holders.has(enemy):
		return true
	if _holders.size() >= max_attackers or _since_grant < grant_spacing:
		return false
	_holders.append(enemy)
	_since_grant = 0.0
	return true


## Devuelve la ficha al terminar el ataque o al morir.
func release_token(enemy: Node3D) -> void:
	if _holders.has(enemy):
		_holders.erase(enemy)


## Saca a un enemigo del encuentro (murió, huyó o se ocultó).
func unregister(enemy: Node3D) -> void:
	_members.erase(enemy)
	release_token(enemy)


func has_token(enemy: Node3D) -> bool:
	return _holders.has(enemy)


func token_count() -> int:
	_prune()
	return _holders.size()


## Empuje plano para separar a un enemigo de sus compañeros.
func separation(enemy: Node3D) -> Vector3:
	var push: Vector3 = Vector3.ZERO
	for other: Node3D in _members:
		if other == enemy or not is_instance_valid(other):
			continue
		var away: Vector3 = enemy.global_position - other.global_position
		away.y = 0.0
		var distance: float = away.length()
		if distance >= separation_distance:
			continue
		if distance < 0.001:
			away = Vector3.RIGHT
			distance = 0.001
		push += away.normalized() * (1.0 - distance / separation_distance)
	return push.limit_length(1.0) * separation_strength


func _prune() -> void:
	for holder: Node3D in _holders.duplicate():
		if not is_instance_valid(holder) or not holder.is_inside_tree():
			_holders.erase(holder)


func _on_member_exiting(enemy: Node3D) -> void:
	_members.erase(enemy)
	release_token(enemy)
