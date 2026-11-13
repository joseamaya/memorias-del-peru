class_name DialogueEffect
extends Resource
## Efecto que produce una línea o una opción de diálogo. Es solo un dato: lo
## aplica [DialogueRunner].

enum Kind {
	SET_FLAG,
	ITEM_ADD,
	ITEM_REMOVE,
	REPUTATION,
}

## Qué se modifica.
@export var kind: Kind = Kind.SET_FLAG
## Bandera, identificador de objeto o grupo de reputación, según el tipo.
@export var key: StringName = &""
## Grupo de reputación; solo se usa con [constant Kind.REPUTATION].
@export var group: StringName = &""
## Cantidad: valor de la bandera, objetos o puntos de reputación.
@export var amount: int = 1
## Objeto que se añade; solo se usa con [constant Kind.ITEM_ADD].
@export var item: ItemDefinition = null
