class_name CharacterCatalog
extends RefCounted
## Catálogo visual de la campaña 01.
##
## El juego sigue usando los modelos MakeHuman/Rocketbox por defecto. Con
## `-- --visual-set=quaternius` (o `PCH_VISUAL_SET=quaternius`) se sustituyen
## solo los papeles del prototipo. Así se comparan ambos sets sin borrar los
## anteriores ni duplicar las escenas.

const QUATERNIUS_MODELS: Dictionary[String, String] = {
	"Mensajero": "pch_npc_mensajero_q.glb",
	"Habitante3": "pch_npc_sisa_q.glb",
	"Curaca": "pch_npc_curaca_q.glb",
	"CuracaVecino": "pch_npc_curaca_q.glb",
	"Chanca": "pch_npc_chanca_q.glb",
	"anciana": "pch_npc_anciana_q.glb",
	"joven": "pch_npc_joven_q.glb",
	"Habitante1": "pch_npc_madre_q.glb",
	"Habitante2": "pch_npc_hermano_q.glb",
	"Principal2": "pch_npc_puma_q.glb",
	"Anca": "pch_npc_anca_q.glb",
	"curaca": "pch_npc_curaca_q.glb",
	"messenger": "pch_npc_mensajero_q.glb",
}


## Verdadero si la partida pidió el set Quaternius. No cambia el valor por
## defecto: una partida normal sigue viendo el elenco anterior.
static func enabled() -> bool:
	if OS.get_environment("PCH_VISUAL_SET") == "quaternius":
		return true
	for argument: String in OS.get_cmdline_user_args():
		if argument == "--visual-set=quaternius" or argument == "visual-set=quaternius":
			return true
	return false


## Modelo de [param role]; si no hay variante Quaternius, conserva el anterior.
static func model_for(role: String, legacy: String) -> String:
	if enabled() and QUATERNIUS_MODELS.has(role):
		return QUATERNIUS_MODELS[role]
	return legacy


## Verdadero si [param file_name] pertenece al prototipo Quaternius.
static func is_quaternius_file(file_name: String) -> bool:
	return file_name.ends_with("_q.glb") or file_name == "pch_npc_chanca_q.glb"
