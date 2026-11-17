"""Extrae una librería compacta de UAL2 para `QuaterniusClips`.

Del paquete Standard gratuito de Universal Animation Library 2 (Quaternius,
CC0) se conservan solo los clips que usa el prototipo. El GLB resultante
mantiene el esqueleto de 65 huesos y el maniquí (necesario para que Godot cree
el `Skeleton3D`), pero no las texturas ni las animaciones no usadas.

Uso:
    blender --background --factory-startup \
        --python campaigns/01_pachacutec/assets/blender/pch_ual2_library.py \
        -- --source "/tmp/opencode/ual2_standard/Universal Animation Library 2[Standard]/Unreal-Godot/UAL2_Standard.glb"
"""

import argparse
import os
import sys

import bpy

SCRIPT_DIR = os.path.dirname(os.path.abspath(__file__))
REPO_DIR = os.path.normpath(os.path.join(SCRIPT_DIR, "..", "..", "..", ".."))
OUT = os.path.join(REPO_DIR, "shared_assets", "characters", "quaternius", "animations",
	"UAL2_Prototype.glb")

# Clips que el prototipo puede mapear. Se dejan también sus variantes de
# recuperación para no cortar acciones compuestas.
KEEP = {
	"Idle_No_Loop",
	"Farm_PlantSeed",
	"Farm_Harvest",
	"TreeChopping_Loop",
	"Hit_Knockback",
	"Melee_Hook",
	"Melee_Hook_Rec",
	"Walk_Carry_Loop",
	"Sword_Block",
	"Yes",
	"Chest_Open",
}


def main():
	parser = argparse.ArgumentParser()
	parser.add_argument("--source", required=True)
	args = parser.parse_args(sys.argv[sys.argv.index("--") + 1:] if "--" in sys.argv else [])
	if not os.path.exists(args.source):
		raise SystemExit("Falta UAL2: %s" % args.source)
	bpy.ops.wm.read_factory_settings(use_empty=True)
	bpy.ops.import_scene.gltf(filepath=args.source)
	armature = None
	meshes = []
	for obj in list(bpy.data.objects):
		if obj.type == "ARMATURE":
			armature = obj
		elif obj.type == "MESH":
			meshes.append(obj)
		else:
			bpy.data.objects.remove(obj, do_unlink=True)
	if armature is None:
		raise SystemExit("UAL2 no trae armadura")
	# Conserva solo los clips usados. Las pistas NLA son las que exporta glTF.
	if armature.animation_data is not None:
		for track in list(armature.animation_data.nla_tracks):
			if track.name not in KEEP:
				armature.animation_data.nla_tracks.remove(track)
		armature.animation_data.action = None
	# Sin texturas: el maniquí no se ve, solo existe para conservar el skin.
	for material in list(bpy.data.materials):
		if material.use_nodes:
			for node in list(material.node_tree.nodes):
				if node.type == "TEX_IMAGE":
					material.node_tree.nodes.remove(node)
	# Exporta armadura + maniquí y las pistas conservadas.
	bpy.ops.object.select_all(action="DESELECT")
	armature.select_set(True)
	for mesh in meshes:
		mesh.select_set(True)
	bpy.context.view_layer.objects.active = armature
	os.makedirs(os.path.dirname(OUT), exist_ok=True)
	bpy.ops.export_scene.gltf(
		filepath=OUT,
		export_format="GLB",
		export_yup=True,
		export_apply=False,
		export_animations=True,
		export_animation_mode="NLA_TRACKS",
		export_skins=True,
		export_cameras=False,
		export_lights=False,
		export_extras=True,
		export_image_format="NONE",
		use_selection=True,
	)
	print("EXPORTED", OUT)


if __name__ == "__main__":
	main()
