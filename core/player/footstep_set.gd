class_name FootstepSet
extends Resource
## Sonidos de paso para un tipo de superficie.
##
## Un cuerpo del mundo declara su superficie con el metadato
## [constant PlayerFPS.FOOTSTEP_SURFACE_META] (por ejemplo, [code]&"stone"[/code]);
## el jugador busca el conjunto cuyo [member surface] coincide. Core no conoce
## superficies concretas: las define cada campaña.

## Identificador de la superficie (coincide con el metadato del suelo).
@export var surface: StringName = &""
## Variantes que se alternan en orden.
@export var streams: Array[AudioStream] = []
