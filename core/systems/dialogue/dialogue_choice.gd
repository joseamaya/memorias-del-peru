class_name DialogueChoice
extends Resource
## Una opción de una línea de diálogo.
##
## [member next_id] puede ser `&"end"` para cerrar la conversación. Si
## [member once] es `true`, la opción desaparece después de elegirla.

## Clave de localización del texto de la opción.
@export var text_key: StringName = &""
## Nodo al que lleva.
@export var next_id: StringName = &"end"
## Condiciones que deben cumplirse para que la opción se muestre.
@export var conditions: Array[DialogueCondition] = []
## Efectos que se aplican al elegirla.
@export var effects: Array[DialogueEffect] = []
## Si es `true`, la opción no vuelve a mostrarse en esta conversación.
@export var once: bool = false
