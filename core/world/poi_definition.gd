class_name PoiDefinition
extends Resource
## Punto de interés de una campaña.
##
## Core interpreta este recurso; la campaña declara ID, nombre, sector,
## clasificación, posición y disparador. La fase se expresa como un rango
## numérico de 0 a 4 para no acoplar el POI al nombre de la fase histórica.

enum Trigger {
	START,
	PROXIMITY,
	DIALOGUE,
	EVENT,
}

@export var id: StringName = &""
@export var display_name: String = ""
@export var description: String = ""
@export var sector: StringName = &""
@export var classification: String = "GN"
@export var trigger: int = Trigger.PROXIMITY
@export var radius: float = 15.0
@export var position: Vector3 = Vector3.ZERO
@export var phase_min: int = 0
@export var phase_max: int = 4


## Indica si el POI puede usarse.
func is_valid() -> bool:
	return id != &"" and not display_name.is_empty() and radius > 0.0


## Indica si la fase del mundo permite descubrirlo.
func is_available(world_stage: int) -> bool:
	return world_stage >= phase_min and world_stage <= phase_max
