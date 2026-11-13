class_name Interactable
extends Node
## Clase base de los objetos interactuables.
##
## El jugador detecta un collider y busca un ancestro de este tipo. Los objetos
## concretos heredan de esta clase y colocan el script en la raíz de su escena.


## Acción de mano que representa la interacción (para las manos en primera
## persona). `none` la desactiva, como en «Hablar».
@export var hand_action: StringName = &"reach"


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
