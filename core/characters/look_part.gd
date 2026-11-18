class_name LookPart
extends Resource
## Pieza de atuendo del maniquí: una forma simple colgada de un hueso.
##
## El maniquí UAL1 no tiene ropa esculpida. Cada pieza es una caja, un cilindro,
## un anillo o un disco, en el espacio del hueso (Y a lo largo del hueso). Es la
## misma idea que usa el proyecto de referencia para sus maniquíes.

enum Shape { BOX, CYLINDER, RING, DISC }

@export var name: String = ""
## Hueso del esqueleto UAL1: spine_02 (pecho), pelvis (cadera), Head, hand_r…
@export var bone: StringName = &"spine_02"
@export var shape: Shape = Shape.BOX
## BOX: ancho, alto, fondo. CYLINDER y DISC: radio, alto. RING: radio interior,
## radio exterior (x, y).
@export var size: Vector3 = Vector3(0.3, 0.3, 0.3)
@export var offset: Vector3 = Vector3.ZERO
@export var rotation_deg: Vector3 = Vector3.ZERO
@export var color: Color = Color.WHITE
