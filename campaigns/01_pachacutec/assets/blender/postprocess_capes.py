"""Post-proceso de mantos y llicllas de los GLB de personajes.

Importa un GLB ya exportado, identifica las caras del paño por la pieza de la
capa UV «Surface» (lliclla = 3, manto = 4) y reduce su apertura lateral hacia
el torso. No toca huesos, pesos, UV ni animaciones. Exporta con NLA tracks,
como el generador original.

Uso:
    blender --background --factory-startup --python postprocess_capes.py -- \\
        entrada.glb salida.glb
"""

import math
import sys

import bpy

Pieces = {3: (0.80, 0.65), 4: (0.78, 0.62)}


def clamp(value, low, high):
	return max(low, min(high, value))


def process(source, target):
	bpy.ops.wm.read_factory_settings(use_empty=True)
	bpy.ops.import_scene.gltf(filepath=source)
	for obj in list(bpy.context.scene.objects):
		if obj.name.startswith("Icosphere"):
			bpy.data.objects.remove(obj, do_unlink=True)
	mesh_obj = bpy.data.objects.get("clothes")
	if mesh_obj is None:
		raise SystemExit("No hay malla 'clothes' en %s" % source)
	surface = mesh_obj.data.uv_layers.get("UVMap")
	if surface is None:
		raise SystemExit("No hay UVMap en %s" % source)
	mesh = mesh_obj.data
	piece_vertices = {piece: set() for piece in Pieces}
	for polygon in mesh.polygons:
		if not polygon.loop_indices:
			continue
		piece = int(round(surface.data[polygon.loop_indices[0]].uv.y))
		if piece not in piece_vertices:
			continue
		for loop_index in polygon.loop_indices:
			piece_vertices[piece].add(mesh.loops[loop_index].vertex_index)
	for piece, vertices in piece_vertices.items():
		if not vertices:
			continue
		zs = [mesh.vertices[index].co.z for index in vertices]
		low, high = min(zs), max(zs)
		top_factor, bottom_factor = Pieces[piece]
		for index in vertices:
			co = mesh.vertices[index].co
			t = clamp((high - co.z) / max(high - low, 1e-6), 0.0, 1.0)
			base = top_factor + (bottom_factor - top_factor) * t
			side = clamp((abs(co.x) - 0.10) / 0.24, 0.0, 1.0)
			factor = 1.0 - (1.0 - base) * side
			co.x *= factor
			co.y += 0.006 * math.sin(co.x * 30.0 + co.z * 12.0) * (0.4 + 0.6 * t)
		print("pieza %d: %d vértices, factor %.2f-%.2f" % (piece, len(vertices), top_factor, bottom_factor))
	mesh.update()
	bpy.context.view_layer.objects.active = mesh_obj
	mesh_obj.select_set(True)
	bpy.ops.object.shade_smooth()
	for obj in bpy.context.scene.objects:
		if obj.type == "ARMATURE" and obj.animation_data:
			obj.animation_data.action = None
			for track in obj.animation_data.nla_tracks:
				track.mute = False
	bpy.ops.export_scene.gltf(
		filepath=target,
		export_format="GLB",
		export_yup=True,
		export_apply=True,
		export_animations=True,
		export_animation_mode="NLA_TRACKS",
		export_skins=True,
		export_cameras=False,
		export_lights=False,
		export_extras=True,
		export_vertex_color="ACTIVE",
		export_image_format="WEBP",
		export_image_quality=88,
		export_texcoords=True,
		export_normals=True,
	)
	print("exportado", target)


if __name__ == "__main__":
	args = sys.argv[sys.argv.index("--") + 1:]
	if len(args) != 2:
		raise SystemExit("Uso: -- entrada.glb salida.glb")
	process(args[0], args[1])
