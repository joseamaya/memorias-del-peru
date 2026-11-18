"""Extrae la mano y el antebrazo derechos del maniquí UAL1 de Quaternius.

El maniquí es un cuerpo skinned de 1,8 m. Para la primera persona no queremos
la mano detallada de UBC: queremos la mano del propio maniquí, con sus dos
superficies (piel y juntas), en un GLB estático.

Uso:
    blender --background --factory-startup --python tools/blender_mannequin_hand.py

Genera `shared_assets/characters/mannequin/mannequin_hand_open.glb`, con el
origen en la muñeca (hueso hand_r) para poder colocarlo delante de la cámara.
"""

import os

import bmesh
import bpy

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
SOURCE = os.path.join(ROOT, "shared_assets", "characters", "mannequin", "ual1_standard.glb")
OUT = os.path.join(ROOT, "shared_assets", "characters", "mannequin", "mannequin_hand_open.glb")
KEEP = ("hand_r", "lowerarm_r")


def main() -> None:
	bpy.ops.wm.read_factory_settings(use_empty=True)
	bpy.ops.import_scene.gltf(filepath=SOURCE)
	armature = next(obj for obj in bpy.data.objects if obj.type == "ARMATURE")
	body = next(obj for obj in bpy.data.objects if obj.type == "MESH" and "Mannequin" in obj.name)
	hand_bone = armature.data.bones["hand_r"]
	wrist = armature.matrix_world @ hand_bone.head_local

	# Copia independiente de la malla, ya en coordenadas de mundo.
	bpy.ops.object.select_all(action="DESELECT")
	body.select_set(True)
	bpy.context.view_layer.objects.active = body
	bpy.ops.object.duplicate()
	hand = bpy.context.object
	hand.name = "MannequinHand"
	hand.parent = None
	hand.matrix_world = body.matrix_world.copy()
	bpy.ops.object.transform_apply(location=False, rotation=True, scale=True)
	for modifier in list(hand.modifiers):
		if modifier.type == "ARMATURE":
			hand.modifiers.remove(modifier)

	# Conserva solo los vértices del antebrazo y la mano derecha.
	group_indices = {
		group.index for group in hand.vertex_groups if group.name in KEEP
	}
	mesh = hand.data
	bm = bmesh.new()
	bm.from_mesh(mesh)
	bm.verts.ensure_lookup_table()
	remove = []
	for vertex in bm.verts:
		weight = 0.0
		for membership in mesh.vertices[vertex.index].groups:
			if membership.group in group_indices:
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
	# El GLB debe nacer en el origen: la muñeca es el pivote local.
	hand.location = (0.0, 0.0, 0.0)

	# Deja solo la mano.
	for obj in list(bpy.data.objects):
		if obj != hand:
			bpy.data.objects.remove(obj, do_unlink=True)
	hand.select_set(True)
	bpy.context.view_layer.objects.active = hand

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
	print("HAND_EXPORTED", OUT, "verts", len(mesh.vertices),
		"wrist", tuple(round(c, 3) for c in wrist))


if __name__ == "__main__":
	main()
