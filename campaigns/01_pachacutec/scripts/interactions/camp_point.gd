class_name CampPoint
extends Interactable
## Punto de conversación del campamento del acto II.
##
## No completa nada: avisa a la escena para que abra el diálogo del curaca.
## El jugador ve la acción en la indicación y pulsa E.

signal requested

@export var prompt_key: StringName = &"PCH_CAMP_TALK"

var _available: bool = true


func _init() -> void:
	# Cuelga del mundo y no tiene malla propia: resaltar al padre encendía toda
	# la escena. Si un punto concreto quiere brillo, asigna highlight_target.
	highlight_parent_if_empty = false


## Permite que la escena retire el punto mientras no tenga sentido (por
## ejemplo, Cusi en el santuario antes de recibir el mensaje).
func set_available(value: bool) -> void:
	_available = value
	# Un punto retirado no debe seguir absorbiendo el rayo ni mostrar «Hablar»:
	# el jugador tiene que poder enfocar lo que hay detrás.
	# El script cuelga de un StaticBody3D, pero la clase base es Node3D para
	# poder compartirse con otros interactuables; la propiedad se asigna por
	# nombre para no romper esa jerarquía.
	set("collision_layer", 4 if value else 0)


func is_available() -> bool:
	return _available


func get_interaction_text() -> String:
	return tr(String(prompt_key))


func interact(_interactor: Node3D) -> void:
	requested.emit()
