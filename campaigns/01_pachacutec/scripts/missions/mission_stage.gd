class_name MissionStage
extends Resource
## Una etapa de misión: encargo del diario y banderas que la completan.
##
## Es solo un dato; [MissionController] decide cuándo entra y cuándo sale. Sin
## motor genérico: las condiciones son banderas de [WorldState].

## Identificador estable de la etapa.
@export var id: StringName = &""
## Clave del título y del cuerpo del encargo en el diario.
@export var title_key: StringName = &""
@export var body_key: StringName = &""
## Banderas que deben estar puestas para completar la etapa.
@export var required_flags: Array[StringName] = []


## Entrada del diario de esta etapa.
func journal_id() -> StringName:
	return StringName("m01_%s" % String(id))


## Indica si todas las banderas de la etapa están puestas.
func is_complete(flags: Dictionary[StringName, int]) -> bool:
	for flag: StringName in required_flags:
		if flags.get(flag, 0) == 0:
			return false
	return not required_flags.is_empty()
