class_name DialogueCondition
extends Resource
## Condición de una opción de diálogo. Es solo un dato: la evalúa
## [DialogueRunner] contra el estado, el inventario y las banderas.

enum Kind {
	FLAG,
	ITEM,
	SKILL,
	REPUTATION,
}

## Qué se comprueba.
@export var kind: Kind = Kind.FLAG
## Bandera, identificador de objeto o nombre de habilidad.
@export var key: StringName = &""
## Grupo de reputación; solo se usa con [constant Kind.REPUTATION].
@export var group: StringName = &""
## Valor mínimo para que la condición se cumpla.
@export var minimum: int = 1
## Invierte el resultado (por ejemplo, «no tiene el objeto»).
@export var negate: bool = false
