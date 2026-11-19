class_name NavmeshProfile
extends Resource
## Parámetros de horneado de un navmesh de sector.
##
## Se declara como recurso para que cada sector ajuste radio de agente,
## pendiente, resolución y muestreo del terreno sin tocar código.

@export var cell_size: float = 0.5
@export var cell_height: float = 0.25
@export var agent_radius: float = 0.5
## Debe ser múltiplo de `cell_height` para que Recast no ajuste la altura.
@export var agent_height: float = 1.75
@export var agent_max_climb: float = 0.5
@export var agent_max_slope: float = 45.0
@export var region_min_size: float = 4.0
## Distancia entre muestras de altura del terreno, en metros.
@export var step: float = 2.0
## Altura de una huella de obstáculo proyectada, en metros.
@export var obstruction_height: float = 3.0
