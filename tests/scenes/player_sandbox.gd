extends Node3D
## Escena sandbox de pruebas del jugador y la interacción.
##
## Compone jugador, HUD, quero y geometría de prueba. No forma parte del juego
## distribuido.

@onready var player: PlayerFPS = $PlayerFPS
@onready var hud: PlayerHud = $UILayer/HUD


func _ready() -> void:
	hud.bind(player, player.stamina)
