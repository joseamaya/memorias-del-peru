class_name CharacterCatalog
extends RefCounted
## Catálogo visual de la campaña 01.
##
## El juego sigue usando los modelos MakeHuman/Rocketbox por defecto. Con
## `-- --visual-set=quaternius` (o `PCH_VISUAL_SET=quaternius`) se sustituyen
## los papeles del prototipo Quaternius. Con `--visual-set=rocketbox` se usa
## el set híbrido: cuerpo y ropa Quaternius con cabeza Rocketbox realista.
## Ningún set alternativo sobrescribe a los demás.

const ROCKETBOX_MODELS: Dictionary[String, String] = {
	"Habitante3": "pch_npc_sisa_rb.glb",
}

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


## Set visual pedido por la partida: "legacy", "quaternius" o "rocketbox".
## No cambia el valor por defecto: una partida normal sigue viendo el elenco
## anterior.
static func mode() -> String:
	var requested: String = OS.get_environment("PCH_VISUAL_SET")
	if requested == "quaternius" or requested == "rocketbox":
		return requested
	for argument: String in OS.get_cmdline_user_args():
		if argument.begins_with("--visual-set="):
			var value: String = argument.trim_prefix("--visual-set=")
			if value == "quaternius" or value == "rocketbox":
				return value
		elif argument.begins_with("visual-set="):
			var value: String = argument.trim_prefix("visual-set=")
			if value == "quaternius" or value == "rocketbox":
				return value
	return "legacy"


## Verdadero si la partida pidió cualquier set alternativo.
static func enabled() -> bool:
	return mode() != "legacy"


## Modelo de [param role]; si no hay variante del set pedido, conserva el
## anterior.
static func model_for(role: String, legacy: String) -> String:
	if mode() == "rocketbox" and ROCKETBOX_MODELS.has(role):
		return ROCKETBOX_MODELS[role]
	if mode() == "quaternius" and QUATERNIUS_MODELS.has(role):
		return QUATERNIUS_MODELS[role]
	return legacy


## Verdadero si [param file_name] pertenece al prototipo Quaternius.
static func is_quaternius_file(file_name: String) -> bool:
	return file_name.ends_with("_q.glb") or file_name == "pch_npc_chanca_q.glb"


## Verdadero si [param file_name] pertenece al set híbrido Rocketbox.
static func is_rocketbox_file(file_name: String) -> bool:
	return file_name.ends_with("_rb.glb")
