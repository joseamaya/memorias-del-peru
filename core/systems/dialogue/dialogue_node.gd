class_name DialogueNode
extends Resource
## Una línea de diálogo con sus opciones y efectos.
##
## Si [member choices] está vacío, la conversación avanza sola a
## [member next_id] con [method DialogueRunner.advance]. Si `next_id` es
## `&"end"`, la conversación termina.

## Identificador del nodo dentro del grafo.
@export var id: StringName = &""
## Clave de localización del nombre del hablante.
@export var speaker_key: StringName = &""
## Clave de localización de la línea.
@export var text_key: StringName = &""
## Nodo siguiente cuando no hay opciones.
@export var next_id: StringName = &"end"
## Opciones visibles según sus condiciones.
@export var choices: Array[DialogueChoice] = []
## Efectos que se aplican la primera vez que se muestra el nodo.
@export var effects: Array[DialogueEffect] = []
