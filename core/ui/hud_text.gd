class_name HudText
extends RefCounted
## Ritmo de lectura compartido por subtítulos, tarjetas e introducción.
##
## Vive fuera de [PlayerHud] para que el HUD congelado no siga creciendo y
## para que las tarjetas de introducción usen la misma regla sin depender del
## nodo del HUD.

## Velocidad de lectura supuesta y margen añadido a cada texto.
const CHARS_PER_SECOND: float = 13.0
const READING_PADDING: float = 1.5
const MIN_SUBTITLE_SECONDS: float = 4.0


## Segundos que necesita [param text] para leerse con calma; nunca menos que
## [param requested] ni que [constant MIN_SUBTITLE_SECONDS].
static func reading_seconds(text: String, requested: float = 0.0) -> float:
	var needed: float = float(text.length()) / CHARS_PER_SECOND + READING_PADDING
	return maxf(maxf(requested, MIN_SUBTITLE_SECONDS), needed)
