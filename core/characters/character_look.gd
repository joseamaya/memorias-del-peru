class_name CharacterLook
extends Resource
## Aspecto de un personaje sobre el maniquí UAL1 compartido.
##
## Dos colores de superficie (cuerpo y juntas) y una lista de piezas simples.
## No hay caras, texturas ni ropa esculpida: la identidad sale de la silueta y
## de los colores, como en los maniquíes de referencia.

## Color de la superficie del cuerpo.
@export var skin: Color = Color(0.55, 0.36, 0.24)
## Color de las juntas: lee como ropa interior o articulación oscura.
@export var joints: Color = Color(0.18, 0.12, 0.1)
@export var parts: Array[LookPart] = []
