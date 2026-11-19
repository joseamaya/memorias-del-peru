class_name ScheduleEntry
extends Resource
## Una franja del horario de un NPC.
##
## `start_minute` y `end_minute` se miden en minutos del día (0–1440). El final
## es exclusivo. Si el inicio es mayor que el final, la franja cruza la
## medianoche; si son iguales, se considera activa todo el día.
##
## `conditions` declara valores que deben coincidir con el estado del mundo
## (por ejemplo, `fase = 1` o `clima = 2`). Una entrada sin condiciones siempre
## coincide.

@export_range(0, 1440, 1) var start_minute: int = 0
@export_range(0, 1440, 1) var end_minute: int = 1440
@export var anchor_id: StringName = &""
@export var activity: StringName = &"idle"
@export var conditions: Dictionary[StringName, int] = {}


## Indica si la franja contiene el minuto indicado.
func contains(minute: int) -> bool:
	var safe_minute: int = clampi(minute, 0, 1439)
	if start_minute == end_minute:
		return true
	if start_minute < end_minute:
		return safe_minute >= start_minute and safe_minute < end_minute
	return safe_minute >= start_minute or safe_minute < end_minute


## Indica si las condiciones del mundo satisfacen esta franja.
func matches(world_conditions: Dictionary[StringName, int]) -> bool:
	for key: StringName in conditions.keys():
		if world_conditions.get(key, 0) != conditions[key]:
			return false
	return true


## Indica si la franja está bien formada.
func is_valid() -> bool:
	if anchor_id == &"":
		return false
	if start_minute < 0 or start_minute > 1440:
		return false
	if end_minute < 0 or end_minute > 1440:
		return false
	return true
