class_name SliceStep
extends Resource
## Un paso de una secuencia de objetivos.
##
## Adaptado del sistema de pasos de la referencia. Cada paso declara qué tiene
## que hacer el jugador, qué marcador lo señala y qué bandera deja al
## completarse. Los pasos se ejecutan en orden y pueden ser opcionales.

enum Act { OPENING, EXPLORATION, SUPPORT, COMBAT, ENDING }
enum Kind { REACH, TASKS, WAIT, DIALOGUE, INTERACT, CHOICE, DRILL }

@export var act: Act = Act.OPENING
@export var kind: Kind = Kind.REACH
## Nombre del marcador de la escena (`Mother`, `Training`, `Plaza`…).
@export var marker: StringName = &""
## Distancia al marcador que cuenta como llegada.
@export_range(0.5, 30.0, 0.5, "suffix:m") var radius: float = 4.0
## Segundos de espera en un paso WAIT.
@export_range(0.0, 60.0, 0.5, "suffix:s") var seconds: float = 0.0
## Texto de la interacción, si el paso usa un punto del mundo.
@export var prompt: StringName = &""
## Lo que el HUD muestra como objetivo. `{count}` se sustituye por el progreso.
@export var objective: StringName = &""
## Aviso que se muestra al completar el paso.
@export var notice: StringName = &""
## Punto de reaparición que fija el paso al empezar.
@export var checkpoint: StringName = &""
## Número de acciones que pide un paso TASKS o DRILL.
@export_range(1, 20, 1) var count: int = 1

@export_group("Flags")
## El jugador puede saltarse el paso.
@export var optional: bool = false
## Bandera que deja el paso al completarse.
@export var flag: StringName = &""
## Solo se juega si esta bandera está puesta.
@export var only_if: StringName = &""
## Solo se juega si esta bandera NO está puesta.
@export var unless: StringName = &""
