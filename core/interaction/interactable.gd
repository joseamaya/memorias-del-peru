class_name Interactable
extends Node3D
## Clase base de los objetos interactuables.
##
## El jugador detecta un collider y busca un ancestro de este tipo. Los objetos
## concretos heredan de esta clase y colocan el script en la raíz de su escena.


## Acción de mano que representa la interacción (para las manos en primera
## persona). `none` la desactiva, como en «Hablar».
@export var hand_action: StringName = &"reach"
## Nodo que se resalta al enfocar el interactuable. Si está vacío se buscan
## mallas dentro del propio interactuable.
@export var highlight_target: Node3D = null
## Si el interactuable no tiene mallas propias, resaltar las de su padre. Los
## puntos de conversación sin visual lo desactivan: su padre es el mundo y el
## resaltado iluminaría la escena entera.
@export var highlight_parent_if_empty: bool = true


## Devuelve si el objeto puede usarse ahora. Los objetos que dependen de un
## estado externo (p. ej. el pututu, que solo convoca durante la reunión) lo
## sobrescriben. Un objeto no disponible no se enfoca ni responde.
func is_available() -> bool:
	return true


## Ejecuta la interacción. Las clases derivadas la sobrescriben.
func interact(_interactor: Node3D) -> void:
	pass


## Texto que se muestra al enfocar el objeto.
func get_interaction_text() -> String:
	return tr("INTERACT_DEFAULT")
