class_name DialogueGraph
extends Resource
## Grafo de una conversación: nodos con opciones, condiciones y efectos.
##
## La campaña crea un `.tres` por conversación. El grafo no conoce la UI ni el
## estado del jugador: [DialogueRunner] lo recorre.

## Nodo por el que empieza la conversación.
@export var entry_id: StringName = &"start"
## Nodos de la conversación.
@export var nodes: Array[DialogueNode] = []


## Busca un nodo por su identificador; devuelve `null` si no existe.
func find_node(node_id: StringName) -> DialogueNode:
	for node: DialogueNode in nodes:
		if node != null and node.id == node_id:
			return node
	return null
