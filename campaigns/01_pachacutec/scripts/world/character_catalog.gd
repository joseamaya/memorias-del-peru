class_name CharacterCatalog
extends RefCounted
## Catálogo único de personajes de la campaña 01.
##
## Todo el elenco usa los diez cuerpos Quaternius (UBC, CC0) con sus clips
## UAL1/UAL2. No hay set anterior ni bandera de selección: los papeles que no
## tienen un modelo propio reutilizan un arquetipo Q. Las alturas y el LOD de
## multitud viven en las escenas.

## Papeles con nombre propio del guion.
const MODELS: Dictionary[String, String] = {
	"Tejedora": "pch_npc_anca_q.glb",
	"Agricultor": "pch_npc_joven_q.glb",
	"Curaca": "pch_npc_curaca_q.glb",
	"CuracaVecino": "pch_npc_curaca_q.glb",
	"Principal2": "pch_npc_puma_q.glb",
	"Habitante1": "pch_npc_madre_q.glb",
	"Habitante2": "pch_npc_hermano_q.glb",
	"Habitante3": "pch_npc_sisa_q.glb",
	"Anca": "pch_npc_anca_q.glb",
	"Mensajero": "pch_npc_mensajero_q.glb",
	"HijoPuma": "pch_npc_joven_q.glb",
	"Herido1": "pch_npc_hermano_q.glb",
	"Herido2": "pch_npc_madre_q.glb",
	"Comitiva1": "pch_npc_madre_q.glb",
	"Comitiva2": "pch_npc_hermano_q.glb",
	"Comitiva3": "pch_npc_joven_q.glb",
	"curaca": "pch_npc_curaca_q.glb",
	"principal": "pch_npc_puma_q.glb",
	"farmer": "pch_npc_joven_q.glb",
	"messenger": "pch_npc_mensajero_q.glb",
	"weaver": "pch_npc_anca_q.glb",
	"anciana": "pch_npc_anciana_q.glb",
	"joven": "pch_npc_joven_q.glb",
	"chanca": "pch_npc_chanca_q.glb",
}

## Rotación de arquetipos para la multitud y los papeles sin modelo propio.
const CROWD: Array[String] = [
	"pch_npc_sisa_q.glb",
	"pch_npc_madre_q.glb",
	"pch_npc_anca_q.glb",
	"pch_npc_anciana_q.glb",
	"pch_npc_joven_q.glb",
	"pch_npc_hermano_q.glb",
	"pch_npc_mensajero_q.glb",
	"pch_npc_puma_q.glb",
	"pch_npc_curaca_q.glb",
	"pch_npc_chanca_q.glb",
]


## Modelo Q de [param role]. [param variant] elige el arquetipo de multitud
## cuando el papel no tiene modelo propio (por ejemplo, `villager`).
static func model_for(role: String, variant: int = 0) -> String:
	if MODELS.has(role):
		return MODELS[role]
	return crowd_model(variant)


## Arquetipo Q determinista para la multitud.
static func crowd_model(variant: int) -> String:
	return CROWD[posmod(variant, CROWD.size())]


## Verdadero si [param file_name] es un GLB del elenco Quaternius.
static func is_quaternius_file(file_name: String) -> bool:
	return file_name.ends_with("_q.glb")
