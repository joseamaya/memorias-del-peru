class_name Interactable
extends Node
## Clase base de los objetos interactuables.
##
## El jugador detecta un collider y busca un ancestro de este tipo. Los objetos
## concretos heredan de esta clase y colocan el script en la raíz de su escena.


## Ejecuta la interacción. Las clases derivadas la sobrescriben.
func interact(_interactor: Node3D) -> void:
	pass


## Texto que se muestra al enfocar el objeto.
func get_interaction_text() -> String:
	return tr("INTERACT_DEFAULT")
