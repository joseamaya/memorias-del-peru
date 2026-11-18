"""Extrae el antebrazo derecho del maniquí UAL1 de Quaternius.

La mano del UAL1 trae los dedos fusionados en la malla y no se puede posar.
Para la primera persona se conserva su antebrazo (con las dos superficies del
maniquí, piel y juntas) y se monta la mano con piezas primitivas en Godot.

Uso:
    blender --background --factory-startup --python tools/blender_mannequin_forearm.py

Genera `shared_assets/characters/mannequin/mannequin_forearm.glb`, con el origen
en la muñeca (hueso hand_r) para poder colocarlo delante de la cámara.
"""

import os

import bmesh
import bpy

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
SOURCE = os.path.join(ROOT, "shared_assets", "characters", "mannequin", "ual1_standard.glb")
OUT = os.path.join(ROOT, "shared_assets", "characters", "mannequin", "mannequin_forearm.glb")
GROUP = "lowerarm_r"


def main() -> None:
	bpy.ops.wm.read_factory_settings(use_empty=True)
	bpy.ops.import_scene.gltf(filepath=SOURCE)
	armature = next(obj for obj in bpy.data.objects if obj.type == "ARMATURE")
	body = next(obj for obj in bpy.data.objects if obj.type == "MESH" and "Mannequin" in obj.name)
	wrist = armature.matrix_world @ armature.data.bones["hand_r"].head_local

	# Copia independiente de la malla, ya en coordenadas de mundo.
	bpy.ops.object.select_all(action="DESELECT")
	body.select_set(True)
	bpy.context.view_layer.objects.active = body
	bpy.ops.object.duplicate()
	forearm = bpy.context.object
	forearm.name = "MannequinForearm"
	forearm.parent = None
	forearm.matrix_world = body.matrix_world.copy()
	bpy.ops.object.transform_apply(location=False, rotation=True, scale=True)
	for modifier in list(forearm.modifiers):
		if modifier.type == "ARMATURE":
			forearm.modifiers.remove(modifier)

	# Conserva solo los vértices del antebrazo derecho.
	group_index = forearm.vertex_groups[GROUP].index
	mesh = forearm.data
	bm = bmesh.new()
	bm.from_mesh(mesh)
	bm.verts.ensure_lookup_table()
	remove = []
	for vertex in bm.verts:
		weight = 0.0
		for membership in mesh.vertices[vertex.index].groups:
			if membership.group == group_index:
				weight = max(weight, membership.weight)
		if weight <= 0.05:
			remove.append(vertex)
	bmesh.ops.delete(bm, geom=remove, context="VERTS")
	bm.to_mesh(mesh)
	bm.free()
	mesh.update()

	# Origen en la muñeca: el nodo gira desde allí en primera persona.
	bpy.context.scene.cursor.location = wrist
	bpy.ops.object.origin_set(type="ORIGIN_CURSOR")
	forearm.location = (0.0, 0.0, 0.0)

	for obj in list(bpy.data.objects):
		if obj != forearm:
			bpy.data.objects.remove(obj, do_unlink=True)
	forearm.select_set(True)
	bpy.context.view_layer.objects.active = forearm

	os.makedirs(os.path.dirname(OUT), exist_ok=True)
	bpy.ops.export_scene.gltf(
		filepath=OUT,
		export_format="GLB",
		export_yup=True,
		export_apply=True,
		export_animations=False,
		export_skins=False,
		export_cameras=False,
		export_lights=False,
		export_materials="EXPORT",
	)
	print("FOREARM_EXPORTED", OUT, "verts", len(mesh.vertices),
		"wrist", tuple(round(c, 3) for c in wrist))


if __name__ == "__main__":
	main()
