class_name NpcDefinition
extends Resource
## Definición de un NPC: identidad, nivel de simulación, anclas y horario.
##
## Es un recurso de contenido de campaña. Core lo interpreta, pero no conoce
## los IDs ni las rutinas concretas. El horario se consulta con el minuto del
## día y el estado del mundo; la primera entrada que coincide gana.

## Niveles de simulación: 0 narrativo, 1 comunidad, 2 ambiente.
enum Tier {
	NARRATIVE,
	COMMUNITY,
	AMBIENT,
}

@export var id: StringName = &""
@export var name_key: StringName = &""
@export var tier: int = Tier.COMMUNITY
@export var home_anchor: StringName = &""
@export var work_anchor: StringName = &""
@export var schedule: Array[ScheduleEntry] = []
@export var faction: StringName = &""
@export var appearance: StringName = &""
@export var dialogue_id: StringName = &""


## Entrada activa para el minuto y las condiciones del mundo, o `null`.
func get_entry(minute: int, world_conditions: Dictionary[StringName, int] = {}) -> ScheduleEntry:
	for entry: ScheduleEntry in schedule:
		if entry == null:
			continue
		if entry.contains(minute) and entry.matches(world_conditions):
			return entry
	return null


## Ancla activa para el minuto. Si no hay entrada, devuelve la casa.
func get_anchor(minute: int, world_conditions: Dictionary[StringName, int] = {}) -> StringName:
	var entry: ScheduleEntry = get_entry(minute, world_conditions)
	if entry != null and entry.anchor_id != &"":
		return entry.anchor_id
	return home_anchor


## Actividad activa para el minuto, o `&"idle"` si no hay entrada.
func get_activity(minute: int, world_conditions: Dictionary[StringName, int] = {}) -> StringName:
	var entry: ScheduleEntry = get_entry(minute, world_conditions)
	if entry != null:
		return entry.activity
	return &"idle"


## Indica si la definición es utilizable y todas sus franjas son válidas.
func is_valid() -> bool:
	if id == &"":
		return false
	for entry: ScheduleEntry in schedule:
		if entry == null or not entry.is_valid():
			return false
	return true
