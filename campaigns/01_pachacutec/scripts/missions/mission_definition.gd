class_name MissionDefinition
extends Resource
## Misión principal de la campaña: etapas en orden y su nombre en el diario.

## Identificador estable de la misión.
@export var id: StringName = &""
## Título de la misión, para el diario y la bitácora de pruebas.
@export var title_key: StringName = &""
## Etapas en orden. La última puede quedar abierta (la cierra otra tarea).
@export var stages: Array[MissionStage] = []


## Etapa por índice (1 = primera). Devuelve `null` si no existe.
func get_stage(index: int) -> MissionStage:
	if index < 1 or index > stages.size():
		return null
	return stages[index - 1]


func get_stage_count() -> int:
	return stages.size()
